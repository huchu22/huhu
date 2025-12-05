from selenium import webdriver
from selenium.common import NoSuchElementException
from selenium.webdriver.common.by import By
from core.pyselenium import Pyselenium
import time
import yaml
import os
from datetime import datetime, timedelta
import re
import psycopg2
from utils.logger import get_logger

class FmkoreaHotDeal(Pyselenium):
    def __init__(self, config_f="fm_best_crawl.yaml"):
        super().__init__()
        self.driver = webdriver.Chrome()

        # 현재 실행 파일 폴더 기준으로 config 파일 지정
        current_dir = os.path.dirname(os.path.abspath(__file__))
        config_path = os.path.join(current_dir, config_f)

        # 설정 config 로드
        with open(config_path, 'r', encoding="utf-8") as f:
            cfg = yaml.safe_load(f)

        # DB 연결
        self.table_name = "total_articles_test"

        self.conn = psycopg2.connect(
            host= "localhost",
            database='postgres',
            user= "postgres",
            password= "9724",
            port= 5432
        )

        self.base_url = cfg['hot_base_url']
        self.headers = {"User-Agent": cfg.get("user_agent")}
        self.wait_time = cfg['wait_time']
        self.is_done = False

        self.site_name = 'hot_deal'
        self.repeat_article = 0

        # 로거 설정
        self.logger = get_logger(self.site_name)

    ###############################################################################################
    def crawl_list(self):
        articles_list = []
        self.repeat_article = 0
        # DB에 있는 게시물들의 article_id 불러오기
        repeat_article = self.load_db_articles()

        list_e = self.driver.find_element(By.CSS_SELECTOR, "div.fm_best_widget._bd_pc")
        content_e = list_e.find_elements(By.CSS_SELECTOR, "li")

        # 게시물 내용 추출
        for e in content_e:
            # 제목 추출
            title_e = e.find_element(By.CSS_SELECTOR, "span.ellipsis-target")
            deal_info_e = e.find_element(By.CSS_SELECTOR, "div.hotdeal_info")
            deal_info = deal_info_e.text.strip()
            title = title_e.text.strip() + " - " + deal_info

            # url 추출
            url = e.find_element(By.CSS_SELECTOR, "a").get_attribute('href')

            # 이미지 url 추출
            try:
                img_e = e.find_element(By.CSS_SELECTOR, "img")
                img_url = img_e.get_attribute('src')
            except NoSuchElementException:
                img_url = ""
                pass

            # 시간 추출
            time_e = e.find_element(By.CSS_SELECTOR, "span.regdate").text.strip()
            create_ts = self.parse_time(time_e)

            # 고유 번호 추출
            match = re.search(r"/(\d+)$", url)
            article_id = self.site_name + "_" + match.group(1)

            if article_id in repeat_article:
                self.repeat_article += 1
                continue

            # 리스트 추가
            articles_list.append({
                'article_id': article_id,
                'article_url': url,
                'title': title,
                'create_ts': create_ts,
                'img_url': img_url
            })
        self.logger.info(f"중복 게시글: {self.repeat_article}개")

        # PostgreSQL DB에 데이터 삽입
        try:
            with self.conn.cursor() as cursor:
                # 데이터 삽입 쿼리
                insert_query = f'''
                        INSERT INTO {self.table_name}
                        (article_id, title,  creation_date, article_url, site_name, img_url, collected_date)
                        VALUES (%s, %s, %s, %s, %s, %s, %s)
                        ON CONFLICT (article_id, site_name) DO NOTHING;
                    '''
                # 한번에 많은 양의 데이터 삽입
                cursor.executemany(insert_query, [
                    (a['article_id'], a['title'], a['create_ts'], a['article_url'], self.site_name, a['img_url'], datetime.now())
                    for a in articles_list
                ])

                self.conn.commit()
                self.logger.info(f"{len(articles_list)}개 수집 완료 및 DB 저장 완료")
        except:
            self.logger.error(f"DB 저장 실패:{e}")
            return

        return

    ###############################################################################################
    def load_db_articles(self):
        with self.conn.cursor() as cursor:
            cursor.execute(f"SELECT article_id FROM {self.table_name} WHERE site_name=%s", (self.site_name,))
            existing_ids = {row[0] for row in cursor.fetchall()}
        return existing_ids
    ###############################################################################################
    @staticmethod
    def parse_time(text):
        now = datetime.now()

        # 1) HH:MM 형식인지 확인
        if ":" in text:
            # HH:MM → time object
            post_time = datetime.strptime(text, "%H:%M").time()

            # 날짜 붙여서 datetime 만들기
            post_dt = datetime.combine(now.date(), post_time)

            # 2) 만약 게시 시간(post_dt)이 현재 시각보다 미래라면 → 전날 게시물
            if post_dt > now:
                post_dt = post_dt - timedelta(days=1)

            return post_dt.strftime("%Y-%m-%d %H:%M")

        # 3) YYYY.MM.DD 형식 처리
        else:
            post_dt = datetime.strptime(text, "%Y.%m.%d")
            return post_dt.strftime("%Y-%m-%d 00:00")  # 시간 정보 없으므로 00:00 지정
    ###############################################################################################
    def start(self):
        try:
            for i in range(1, 11):
                url = f"{self.base_url}{i}"
                # self.is_done = True
                self.driver.get(url)
                time.sleep(self.wait_time)
                self.logger.info(f"수집 URL: {url}")
                self.crawl_list()

        except Exception as e:
            self.logger.error(f"Error: {e}")
        finally:
            # 디버깅 중 강제 종료나 예외가 나도 Chrome 종료
            if self.driver:
                self.driver.close()
            if self.conn:
                self.conn.close()

if __name__ == "__main__":
    crawler = FmkoreaHotDeal()
    crawler.start()

from selenium import webdriver
from selenium.webdriver.common.by import By
from core.pyselenium import Pyselenium
import time
import yaml
import os
from datetime import datetime, timedelta
import re
import psycopg2

class FmkoreaBest(Pyselenium):
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
        self.table_name = "total_articles"

        self.conn = psycopg2.connect(
            host= "localhost",
            database='postgres',
            user= "postgres",
            password= "9724",
            port= 5432
        )

        self.base_url = cfg['base_url']
        self.headers = {"User-Agent": cfg.get("user_agent")}
        self.wait_time = cfg['wait_time']
        self.is_done = False

        self.site_name = 'fmkorea'

    ###############################################################################################
    def crawl_list(self):
        articles_list = []
        # DB에 있는 게시물들의 article_id 불러오기
        repeat_article = self.load_db_articles()

        list_e = self.driver.find_element(By.CSS_SELECTOR, "div.fm_best_widget._bd_pc")
        content_e = list_e.find_elements(By.CSS_SELECTOR, "li")

        # 게시물 내용 추출
        for e in content_e:
            # 제목 추출
            title_e = e.find_element(By.CSS_SELECTOR, "span.ellipsis-target")
            title = title_e.text.strip()

            # url 추출
            url = e.find_element(By.CSS_SELECTOR, "a").get_attribute('href')

            # 시간 추출
            time_e = e.find_element(By.CSS_SELECTOR, "span.regdate").text.strip()
            time_t = self.parse_relative_time(time_e)
            create_ts = time_t.strftime("%Y-%m-%d %H:%M")

            # 고유 번호 추출
            match = re.search(r"/(\d+)$", url)
            article_id = self.base_url + "_" + match.group(1)

            if article_id in repeat_article:
                continue

            # 리스트 추가
            articles_list.append({
                'article_id': article_id,
                'article_url': url,
                'title': title,
                'create_ts': create_ts
            })

        # PostgreSQL DB에 데이터 삽입
        try:
            with self.conn.cursor() as cursor:
                # 데이터 삽입 쿼리
                insert_query = f'''
                        INSERT INTO {self.table_name}
                        (article_id, title,  creation_date, article_url, site_name, collected_date)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        ON CONFLICT (article_id, site_name) DO NOTHING;
                    '''
                # 한번에 많은 양의 데이터 삽입
                cursor.executemany(insert_query, [
                    (a['article_id'], a['title'], a['create_ts'], a['article_url'], self.site_name, datetime.now())
                    for a in articles_list
                ])

                self.conn.commit()
        except:
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
    def parse_relative_time(text: str) -> datetime:

        # '7 시간 전', '3일 전', '5분 전' 등을 시간으로 변경

        text = text.strip()
        now = datetime.now()

        match = re.match(r"(\d+)\s*(초|분|시간|일|주|개월|년) 전", text)
        if not match:
            return datetime.now()

        num, unit = match.groups()
        num = int(num)

        if unit == "초":
            delta = timedelta(seconds=num)
        elif unit == "분":
            delta = timedelta(minutes=num)
        elif unit == "시간":
            delta = timedelta(hours=num)
        elif unit == "일":
            delta = timedelta(days=num)
        elif unit == "주":
            delta = timedelta(weeks=num)
        elif unit == "개월":
            delta = timedelta(days=num * 30)
        elif unit == "년":
            delta = timedelta(days=num * 365)
        else:
            delta = timedelta(0)

        return now - delta
    ###############################################################################################
    def start(self):
        try:
            for i in range(1, 10):
                url = f"{self.base_url}{i}"
                # self.is_done = True
                self.driver.get(url)
                time.sleep(self.wait_time)
                self.crawl_list()

        except Exception as e:
            print("❌ Error:", e)
        finally:
            # 디버깅 중 강제 종료나 예외가 나도 Chrome 종료
            if self.driver:
                self.driver.close()
            if self.conn:
                self.conn.close()

if __name__ == "__main__":
    crawler = FmkoreaBest()
    crawler.start()

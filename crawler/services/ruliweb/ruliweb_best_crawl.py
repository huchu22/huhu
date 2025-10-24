from selenium import webdriver
from bs4 import BeautifulSoup
from crawler.core.pyselenium import Pyselenium
import time
import yaml
import os
from datetime import datetime, timedelta
import re
import logging
import psycopg2

class RuliwebBest(Pyselenium):
    def __init__(self, config_f="ruliweb_best_crawl.yaml"):
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

        self.site_name = 'ruliweb'

    ###############################################################################################
    def crawl_list(self):
        articles_list = []
        # DB에 있는 게시물들의 article_id 불러오기
        repeat_article = self.load_db_articles()

        html_source = self.driver.page_source
        soup = BeautifulSoup(html_source, 'html.parser')

        article_list = soup.find('div', class_= "board_main theme_default")
        contents_e =  article_list.find_all('tr', class_= "table_body blocktarget")

        # 게시물 내용 추출
        for e in contents_e:
            # 제목 추출
            title_e = e.find('div', class_ = "title row").find('a')
            cate_e = title_e.find('span', class_= 'subject_tag')
            if cate_e:
                cate_e.decompose()
            title = title_e.text.strip()
            # url 추출
            a_url = title_e['href']
            url =  a_url
            # 시간 추출
            now = datetime.now().strftime('%Y-%m-%d')
            time_e = e.find('div', class_ = "info row").find('span', class_="time")
            create_ts = f"{now} {time_e.text.strip()}"

            # 고유 번호 추출
            match = re.search(r'/read/(\d+)', url)
            if match:
                article_id = "ruliweb" + "_" + match.group(1)

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
            self.conn.rollback()
            return

        return

    ###############################################################################################
    def load_db_articles(self):
        with self.conn.cursor() as cursor:
            cursor.execute(f"SELECT article_id FROM {self.table_name} WHERE site_name=%s", (self.site_name,))
            existing_ids = {row[0] for row in cursor.fetchall()}
        return existing_ids

    ###############################################################################################
    def start(self):
        try:
            for i in range(1, 5):
                url = f"{self.base_url}{i}"
                self.driver.get(url)
                self.crawl_list()

        except Exception as e:
            print("❌ Error:", e)
        finally:
            # 디버깅 중 강제 종료나 예외가 나도 Chrome 종료
            if self.driver:
                self.driver.quit()
            if self.conn:
                self.conn.close()

if __name__ == "__main__":
    crawler = RuliwebBest()
    crawler.start()

from selenium import webdriver
from bs4 import BeautifulSoup
from core.pyselenium import Pyselenium
import yaml
import os
from datetime import datetime, timedelta
import psycopg2
from utils.logger import get_logger

class DcinsideBest(Pyselenium):
    def __init__(self, config_f="dc_best_crawl.yaml"):
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

        self.site_name = 'dcinside'
        self.repeat_article = 0

        # 로거 설정
        self.logger = get_logger(self.site_name)

    ###############################################################################################
    def crawl_list(self):
        articles_list = []
        self.repeat_article = 0
        # DB에 있는 게시물들의 article_id 불러오기
        repeat_article = self.load_db_articles()

        html_source = self.driver.page_source
        soup = BeautifulSoup(html_source, 'html.parser')

        article_list = soup.find('tbody', class_= "listwrap2")
        contents_e =  article_list.find_all('tr', class_= "ub-content us-post thum")
        self.logger.info(f"게시글 수: {len(contents_e)}개")

        # 게시물 내용 추출
        for e in contents_e:
            # 제목 추출
            title_e = e.find('td', class_ = "gall_tit ub-word").find('a')
            strong_e = title_e.find('strong')
            if strong_e:
                strong_e.decompose()
            title = title_e.text.strip()
            # url 추출
            base_url = 'https://gall.dcinside.com'
            a_url = title_e['href']
            url = base_url + a_url
            # 시간 추출
            time_e = e.find('td', class_="gall_date")
            create_ts = time_e['title']
            # 고유 번호 추출
            article_id = self.site_name + "_" + url.split('no=')[1].split('&')[0]

            if article_id in repeat_article:
                self.repeat_article += 1
                continue
            # 리스트 추가
            articles_list.append({
                'article_id': article_id,
                'article_url': url,
                'title': title,
                'create_ts': create_ts
            })
        self.logger.info(f"중복 게시글: {self.repeat_article}개")
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
                self.logger.info(f"{len(articles_list)}개 수집 완료 및 DB 저장 완료")
        except Exception as e:
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
    def start(self):
        try:
            self.logger.info(f"🚀 {self.site_name} 인기글 크롤링 시작")
            for i in range(1, 5):
                url = f"{self.base_url}{i}"
                self.driver.get(url)
                self.logger.info(f"수집 URL: {url}")
                self.crawl_list()

        except Exception as e:
            self.logger.error(f"Error: {e}")
        finally:
            # 디버깅 중 강제 종료나 예외가 나도 Chrome 종료
            if self.driver:
                self.driver.quit()
            if self.conn:
                self.conn.close()

if __name__ == "__main__":
    crawler = DcinsideBest()
    crawler.start()

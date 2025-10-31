import os
import time
import logging
from datetime import datetime

# --- 각 사이트 크롤러 import ---
from services.fmkorea.fm_best_crawl import FmkoreaBest
from services.dcinside.dc_best_crawl import DcinsideBest
from services.ruliweb.ruliweb_best_crawl import RuliwebBest
from services.theqoo.theqoo_hot_crawl import TheqooHot

# 로그 설정
LOG_DIR = os.path.join(os.path.dirname(__file__), "logs")
os.makedirs(LOG_DIR, exist_ok=True)

log_filename = os.path.join(LOG_DIR, f"crawl_{datetime.now():%Y%m%d}.log")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(log_filename, encoding="utf-8"),
        logging.StreamHandler(),  # 콘솔 출력도 같이
    ],
)

logger = logging.getLogger(__name__)

# 크롤러 실행 함수
def run_crawler(crawler_cls, name):
    try:
        logger.info(f"🚀 {name} 크롤링 시작")
        crawler = crawler_cls()
        crawler.start()
        logger.info(f"✅ {name} 크롤링 완료\n")
    except Exception as e:
        logger.exception(f"❌ {name} 크롤링 실패: {e}")

# 메인 실행
def main():
    logger.info("=" * 50)
    logger.info("🕷️ 크롤링 프로세스 시작")

    crawlers = [
        ("FMKOREA", FmkoreaBest),
        ("DCINSIDE", DcinsideBest),
        ("RULIWEB", RuliwebBest),
        ("THEQOO", TheqooHot),
    ]

    for name, crawler_cls in crawlers:
        run_crawler(crawler_cls, name)
        time.sleep(3)  # 사이트 간 요청 간격

    logger.info("🎯 모든 사이트 크롤링 완료")
    logger.info("=" * 50)

if __name__ == "__main__":
    main()

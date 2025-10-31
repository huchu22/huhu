import logging
import os
from datetime import datetime

def get_logger(site_name: str):
    """
    사이트별 전용 로거 생성
    :param site_name: 예) 'dcinside', 'ruliweb'
    :return: logger 객체
    """

    # logs/ 하위에 사이트별 폴더 생성
    base_log_dir = os.path.join(os.path.dirname(__file__), '..', 'logs', site_name)
    os.makedirs(base_log_dir, exist_ok=True)

    # 날짜별 로그 파일명
    log_filename = datetime.now().strftime('%Y-%m-%d') + '.log'
    log_path = os.path.join(base_log_dir, log_filename)

    # 로거 생성
    logger = logging.getLogger(f"{site_name}_logger")
    logger.setLevel(logging.INFO)

    # 중복 핸들러 방지
    if logger.hasHandlers():
        return logger

    # 콘솔 핸들러
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)

    # 파일 핸들러
    file_handler = logging.FileHandler(log_path, encoding='utf-8')
    file_handler.setLevel(logging.INFO)

    # 포맷 설정
    formatter = logging.Formatter(
        '[%(asctime)s] [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    console_handler.setFormatter(formatter)
    file_handler.setFormatter(formatter)

    # 핸들러 추가
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    return logger

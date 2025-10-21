package com.huhu.demo.articles.repository;

import com.huhu.demo.articles.dto.ArticleDto;
import com.huhu.demo.articles.entity.ArticleEntity;
import com.huhu.demo.articles.entity.ArticleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;

public interface ArticleRepository extends JpaRepository<ArticleEntity, ArticleId> {
    // 사이트 이름으로 게시글 분리
    List<ArticleEntity> findBySiteName(String siteName);

    List<ArticleEntity> findAllByOrderByCollectedDateDesc();
}

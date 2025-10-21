package com.huhu.demo.articles.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "article_read_status")
public class ArticleReadStatusEntity {
    @Id
    private String articleId;

    @Id
    private String siteName;
}

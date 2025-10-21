package com.huhu.demo.articles.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "total_articles")
@IdClass(ArticleId.class)
public class ArticleEntity {
    @Id
    @Column(name = "article_id")
    private String articleId;

    @Id
    @Column(name = "site_name")
    private String siteName;

    @Column(name = "title")
    private String title;

    @Column(name = "article_url", length = 2048)
    private String articleUrl;

    @Column(name = "creation_date")
    private LocalDateTime creationDate;

    @Column(name = "collected_date")
    private  LocalDateTime collectedDate;
}

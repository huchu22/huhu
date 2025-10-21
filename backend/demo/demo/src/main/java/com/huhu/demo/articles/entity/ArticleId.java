package com.huhu.demo.articles.entity;

import java.io.Serializable;
import java.util.Objects;

public class ArticleId implements Serializable {
    private String articleId;
    private String siteName;

    public ArticleId() {}

    public ArticleId(String articleId, String siteName) {
        this.articleId = articleId;
        this.siteName = siteName;
    }

    // Unique 확인
    @Override
    public boolean equals(Object o){
        if (this == o) return true;
        if(!(o instanceof  ArticleId)) return false;
        ArticleId that = (ArticleId) o;
        return Objects.equals(articleId, that.articleId)
                && Objects.equals(siteName, that.siteName);
    }

    @Override
    public int hashCode() {
        return Objects.hash(articleId, siteName);
    }
}

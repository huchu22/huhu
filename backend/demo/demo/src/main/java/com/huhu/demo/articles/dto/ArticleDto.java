package com.huhu.demo.articles.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import com.huhu.demo.common.SiteNameMapping;

import java.time.LocalDateTime;

@Schema(description = "게시글 요청 DTO")
// json 보내주는 형식 변경 annotation
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "YYYY.MM.dd HH:mm")
public class ArticleDto {
    private String title;
    private LocalDateTime creationDate;
    private String siteUrl;
    private String siteName;

    public ArticleDto(String title, LocalDateTime creationDate, String siteUrl, String siteName) {
        this.title = title;
        this.creationDate = creationDate;
        this.siteUrl = siteUrl;
        this.siteName = SiteNameMapping.getDisplayName(siteName);
    }

    public String getTitle() {return title;}
    public LocalDateTime getCreationDate() {return creationDate;}
    public String getSiteUrl() {return siteUrl;}
    public String getSiteName() {return siteName;}

    public void setTitle(String title) {this.title = title;}
    public void setCreationDate(LocalDateTime creationDate) {this.creationDate = creationDate;}
    public void setSiteUrl(String siteUrl) {this.siteUrl = siteUrl;}
    public void setSiteName(String siteName) {this.siteName = siteName;}
}

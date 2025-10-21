package com.huhu.demo.articles.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;

@Schema(description = "게시글 요청 DTO")
// json 보내주는 형식 변경 annotation
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "YYYY.MM.dd HH:mm")
public class ArticleDto {
    private String title;
    private LocalDateTime creationDate;
    private String siteUrl;

    public ArticleDto(String title, LocalDateTime creationDate, String siteUrl) {
        this.title = title;
        this.creationDate = creationDate;
        this.siteUrl = siteUrl;
    }

    public String getTitle() {return title;}
    public LocalDateTime getCreationDate() {return creationDate;}
    public String getSiteUrl() {return siteUrl;}

    public void setTitle(String title) {this.title = title;}
    public void setCreationDate(LocalDateTime creationDate) {this.creationDate = creationDate;}
    public void setSiteUrl(String siteUrl) {this.siteUrl = siteUrl;}
}

package com.huhu.demo.articles.controller;

import com.huhu.demo.articles.dto.ArticleDto;
import com.huhu.demo.articles.service.ArticleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@Tag(name = "Articles", description = "게시글 관리 API")
@RequestMapping("/api/articles")
@CrossOrigin
@RequiredArgsConstructor
public class ArticleController {
    private final ArticleService articleService;

    // 사이트명 조회
    @Operation(summary = "사이트명 조회")
    @GetMapping("/sitename/{sitename}")
    public List<ArticleDto> getArticlesBySiteName(@PathVariable String sitename){
        return articleService.getArticleListBySiteName(sitename);
    }

    // 전체 리스트
    @Operation(summary = "전체 리스트 조회")
    @GetMapping
    public List<ArticleDto> getAllArticles(){
        return articleService.getAllArticles();
    }
}

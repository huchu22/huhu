package com.huhu.demo.articles.service;

import com.huhu.demo.articles.dto.ArticleDto;
import com.huhu.demo.articles.repository.ArticleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ArticleService {
    private final ArticleRepository articleRepository;

    // 사이트 이름으로 조회
    public List<ArticleDto> getArticleListBySiteName(String siteName){
        return articleRepository.findBySiteName(siteName)
                .stream()
                // Dto와 순서 맞춰야 한다...
                .map(a -> new ArticleDto(a.getTitle(),a.getCreationDate(), a.getArticleUrl()))
                .collect(Collectors.toList());
    }

    // 전체 리스트
    public List<ArticleDto> getAllArticles(){
        return articleRepository.findAllByOrderByCollectedDateDesc()
                .stream()
                .map(a -> new ArticleDto(a.getTitle(),a.getCreationDate(), a.getArticleUrl()))
                .collect(Collectors.toList());
    }
}

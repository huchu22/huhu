package com.huhu.demo.common;

public enum SiteNameMapping {
    FMKOERA("fmkorea", "에펨코리아"),
    DCINSIDE("dcinside", "디시인사이드"),
    NAVER("naver", "네이버카페"),
    THEQOO("theqoo", "더쿠"),
    RULIWEB("ruliweb", "루리웹");

    private final String code;
    private final String name;

    SiteNameMapping(String code, String name){
        this.code = code;
        this.name = name;
    }

    public static String getDisplayName(String code) {
        for (SiteNameMapping s: values()){
            if (s.code.equals(code)) return s.name;
        }
        return code;
    }
}

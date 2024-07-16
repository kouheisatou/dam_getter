String DAM_LOGIN_SUCCEEDED_PAGE = "https://www.clubdam.com/app/damtomo/SP/MyPage.do";
String DAM_MYPAGE_URL = "https://www.clubdam.com/app/damtomo/MyPage.do";
Map<String, String> SCORE_TYPES = {
  "精密採点Ai": "https://www.clubdam.com/app/damtomo/scoring/GetScoringAiListXML.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&pageNo=\${pageNo}&detailFlg=1&UTCserial=\${UTCserial}",
  "精密採点DX-G": "https://www.clubdam.com/app/damtomo/scoring/GetScoringDxgListXML.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&pageNo=\${pageNo}&detailFlg=1&dxgType=1&UTCserial=\${UTCserial}",
  "精密採点DX デュエット": "https://www.clubdam.com/app/damtomo/scoring/GetScoringDxgListXML.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&pageNo=\${pageNo}&detailFlg=1&dxgType=2&UTCserial=\${UTCserial}",
  "精密採点DX ミリオン": "https://www.clubdam.com/app/damtomo/scoring/GetScoringMillionHistoryListXML.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&favoriteFlg=0&pageNo=\${pageNo}&sort=2&UTCserial=\${UTCserial}",
  "ランキングバトル ONLINE": "https://www.clubdam.com/app/xml/membership/damtomo/rankingList.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&page=\${pageNo}&UTCserial=\${UTCserial}",
  "完唱! 歌いきりまショー!!": "https://www.clubdam.com/app/xml/membership/damtomo/utaikiriList.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&page=\${pageNo}&UTCserial=\${UTCserial}",
  "精密採点DX": "https://www.clubdam.com/app/damtomo/membership/MarkingDxListXML.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&pageNo=\${pageNo}&UTCserial=\${UTCserial}",
  "精密採点Ⅱ": "https://www.clubdam.com/app/xml/membership/damtomo/markingTwoList.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&pageNo=\${pageNo}&UTCserial=\${UTCserial}",
  "精密採点Ⅰ（プラス）": "https://www.clubdam.com/app/xml/membership/damtomo/markingList.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&pageNo=\${pageNo}&UTCserial=\${UTCserial}",
  "シンプル採点": "https://www.clubdam.com/app/damtomo/membership/SimpleListXML.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&pageNo=\${pageNo}&UTCserial=\${UTCserial}",
  "DAMボイストレーニング": "https://www.clubdam.com/app/damtomo/membership/TrainingListXML.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&UTCserial=\${UTCserial}",
  "カロリーりれき": "https://www.clubdam.com/app/damtomo/member/info/CalorieHistoryListXML.do?cdmCardNo=\${cdmCardNo}&cdmToken=\${cdmToken}&enc=sjis&pageNo=\${pageNo}&date=undefined&UTCserial=\${UTCserial}",
};

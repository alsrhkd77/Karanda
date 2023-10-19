import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TradeMarketProvider {
  List urls = [
    Uri.parse(
        'https://trade.kr.playblackdesert.com/Trademarket/GetMarketPriceInfo'),
    Uri.parse(
        'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketWaitList'),
    Uri.parse(
        'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketSearchList'),
    Uri.parse(
        'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketSubList'),
    Uri.parse(
        'https://trade.kr.playblackdesert.com/Trademarket/GetBiddingInfoList'), //잘안됨
    Uri.parse(
        'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketList'),
    Uri.parse(
        'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketHotList'), //안됨
  ];
  String token = "1N4x4hfihUSoe9ETA8fn0dISRSyf2PQvDYtxEtv3F7Qg";

  Future<void> getData() async {
    await marketSubList();
    //await marketSearchList();
    var response = await http.post(
      Uri.parse(
          'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketHotList'),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
        //"Content-Type": "application/json",
        //"User-Agent": "BlackDesert",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "ko-KR,ko;q=0.9",
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
        //"Content-Length": "0",
        //"X-Requested-With": "XMLHttpRequest",
      },
    );
    //print(response.headers);
    //var gzip = GZipCodec().decode(response.bodyBytes);
    //var data = utf8.decode(gzip);
    //print(data);
  }

  Future<void> marketList() async {
    /* 안됨 */
    var response = await http.post(
        Uri.parse(
            'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketList'),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          //"Content-Type": "application/json",
          //"User-Agent": "BlackDesert",
          "Accept-Encoding": "gzip, deflate, br",
          "Accept-Language": "ko-KR,ko;q=0.9",
          "Dnt": "1",
        },
        body: jsonEncode({
          //"keyType": 0,
          "mainCategory": 20,
          "subCategory": 1,
        }));
    print(response.headers);
    print(response.body);
    var gzip = GZipCodec().decode(response.bodyBytes);
    var data = utf8.decode(gzip);
    print(data);
  }

  Future<void> marketSubList() async {
    /* 
    쿠키, RequestVerificationToken 바꿔가면서 써야함
    실패 response.body {"resultCode":2000,"resultMsg":"TRADE_MARKET_ERROR_MSG_UNAUTHORIZED","redirectUrl":"https://trade.kr.playblackdesert.com/Pearlabyss/Index"}
     */
    var response = await http.post(
      Uri.parse(
          'https://trade.kr.playblackdesert.com/Home/GetWorldMarketSubList'),
      headers: {
        //"Content-Type": "application/json",
        //"User-Agent": "BlackDesert",
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "ko-KR,ko;q=0.9",
        "Accept": "*/*",
        "Host": "trade.kr.playblackdesert.com",
        "Origin": "https://trade.kr.playblackdesert.com",
        "Referer": "https://trade.kr.playblackdesert.com/Home/list/1-2",
        "Sec-Ch-Ua":
            "\"Chromium\";v=\"118\", \"Google Chrome\";v=\"118\", \"Not=A?Brand\";v=\"99\"",
        "Sec-Ch-Ua-Mobile": "?0",
        "Sec-Ch-Ua-Platform": "Windows",
        "Sec-Fetch-Dest": "empty",
        "Sec-Fetch-Mode": "cors",
        "Sec-Fetch-Site": "same-origin",
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36",
        "X-Requested-With": "XMLHttpRequest",
        "Cookie":
            "lang=ko-KR; kr.Session=4w4gbvx3tpx3310xp4fwtqf2; visid_incap_2512157=wY+inQrQSdiMD++TxqemeAMhMWUAAAAAQUIPAAAAAAD8AoPhlJOOykEUO29ztHqi; nlbi_2512157=TH5MLzZVSm19Bi4dcr2evwAAAABHBCmEMP3y3Qio9ausHYAU; rating=PEGI; blackdesert_cid=KZWZKZIHME2KA2I7245O; _gcl_au=1.1.300328338.1697718547; _gid=GA1.2.1463212154.1697718547; _fbp=fb.1.1697718546849.1621255822; _ga_B3YXM190FN=GS1.1.1697718546.1.1.1697718578.0.0.0; _ga=GA1.2.1491604269.1697718547; _ga_0GDFQ7CSY2=GS1.1.1697718546.1.1.1697718859.60.0.0; visid_incap_2512902=dTMDFpUqS4mZ3q0RG1ZApD0iMWUAAAAAQUIPAAAAAACR/RKuy0eo9dXGia7Hir6W; nlbi_2512902=22bfPmLz22w3qN0hfdwC7gAAAACPs8WEdazC4a7cQ27UAvTI; incap_ses_950_2512902=RPq2Kil+zTNN6J8GLRQvDT0iMWUAAAAAQwdEjYyEgnOJwSk4iGx3pA==; TradeAuth_Session=v2tflj3knefhlanxhpyw11i5; __RequestVerificationToken=RM4tnOl4v7Ksd_CrSUtKfyZJpGaqC-Nv4CGE7DKYde62xkIVXsgz4dkALdiQZmfjdmGhIXivO1N5IL537h0CS6TnkcJP3HcGvwOXbZeXTJU1; incap_ses_950_2512157=u3//Bw9E7jE5/qIGLRQvDUgoMWUAAAAAuo62cGmCgy3UQX4kYyeH3g==; nlbi_2512157_2147483392=b5MQeVYdpWvFsJpacr2evwAAAABMjzLhyCZi+axgGt+QLJUs; _gat=1; _ga_1YED0GQH79=GS1.2.1697722500.2.1.1697722504.0.0.0",
        //"Dnt": "1",
        //"Content-Length": "164",
      },
      encoding: Encoding.getByName("utf-8"),
      body:
          "__RequestVerificationToken=jfdS_YTJlX-wKqG4UDfd3ZEAIQ7lnS7VSu7Q9DWYsJeN1nYiUakluQ9aeUGE4Z9WLACMU9cwYqAFepKQCr-WtZkzk1gfc7ENAPPJ_oiZVxw1&mainKey=715003&usingCleint=0",
      //body: "__RequestVerificationToken=${token}mainKey=715003&usingCleint=0",
      /*
      body: jsonEncode({
        //"keyType": "0",
        "__RequestVerificationToken":
            "K73Gu_KjZAuTLa7U2P8WV2rR5GsaPGbUUy3iOLu4nabNvHyTNm6q8xl1WMbcfOjN8CVM5P36AsF2wfkL-z1TU7zvlH90CE_VLWirCsWfFgg1",
        "mainKey": "715003",
        "usingCleint": "0",
        //"subCategory": 1,
      }),
      */
    );
    print(response.headers);
    print(response.body);
    //var gzip = GZipCodec().decode(response.bodyBytes);
    //var data = utf8.decode(gzip);
    //print(data);
  }

  Future<void> marketSearchList() async {
    /* 응답 양식
    Item ID - 등록 갯수 - 기준 가격 - 총 거래량
     */
    var response = await http.post(
        Uri.parse(
            'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketSearchList'),
        headers: {
          //"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          "Content-Type": "application/json",
          "User-Agent": "BlackDesert",
          //"Accept-Encoding": "gzip, deflate, br",
          //"Accept-Language": "ko-KR,ko;q=0.9",
          //"Dnt": "1",
        },
        body: jsonEncode({
          "searchResult": "11853, 12061, 715003",
        }));
    print(response.headers);
    print(response.body);
    var gzip = GZipCodec().decode(response.bodyBytes);
    var data = utf8.decode(gzip);
    print(data);
  }

  Future<void> marketSellBuyInfo() async {
    /* 안됨 */
    var response = await http.post(
      Uri.parse(
          'https://trade.kr.playblackdesert.com/Trademarket/GetWorldMarketSubList'),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
        //"Content-Type": "application/json",
        //"User-Agent": "BlackDesert",
        "Accept-Encoding": "gzip, deflate, br",
        //"Accept-Language": "ko-KR,ko;q=0.9",
        //"Dnt": "1",
      },
      body: jsonEncode({
        //"keyType": "0",
        //"_RequestVerificationToken":"g7512mQdqbZN4221v0qr3TShG1R2Xyz8_Znp24c2XsMur7kWv3a2JUkZ9SbxaOUOC_OnFHt5qFwAE6e7p8oulb2LyVDcyyMBKfPNLjYttzk1",
        "mainKey": "529",
        //"usingCleint": 0,
        //"subKey": "0",
      }),
    );
    print(response.headers);
    print(response.body);
    var d = response.bodyBytes.sublist(0);
    //print(d);
    //var gzip = GZipCodec().decode(d);
    //var data = utf8.decode(gzip);
    var data = utf8.decode(d);
    //print(data);
  }

  Future<void> marketBiddingInfo() async {
    /* 안됨 */
    var response = await http.post(
        Uri.parse(
            'https://trade.kr.playblackdesert.com/Trademarket/GetBiddingInfoList'),
        //Uri.parse('https://trade.kr.playblackdesert.com/Trademarket/GetSellBuyInfo'),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          //"Content-Type": "application/json",
          //"User-Agent": "BlackDesert",
          "Accept-Encoding": "gzip, deflate, br",
          //"Accept-Language": "ko-KR,ko;q=0.9",
          //"Dnt": "1",
        },
        body: jsonEncode({
          "keyType": "0",
          "mainKey": "528",
          "subKey": "0",
        }));
    print(response.headers);
    print(response.body);
    var d = response.bodyBytes.sublist(0);
    //print(d);
    //var gzip = GZipCodec().decode(d);
    //var data = utf8.decode(gzip);
    var data = utf8.decode(d);
    print(data);
  }

  Future<void> marketPriceInfo() async {
    /* 응답 양식
    최근 90일 가격 변동 추이
    첫번째 값이 90일 전
     */
    var response = await http.post(
        Uri.parse(
            'https://trade.kr.playblackdesert.com/Trademarket/GetMarketPriceInfo'),
        //Uri.parse('https://trade.kr.playblackdesert.com/Trademarket/GetSellBuyInfo'),
        headers: {
          //"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          "Content-Type": "application/json",
          "User-Agent": "BlackDesert",
          //"Accept-Encoding": "gzip, deflate, br",
          //"Accept-Language": "ko-KR,ko;q=0.9",
          //"Dnt": "1",
        },
        body: jsonEncode({
          "keyType": "0",
          "mainKey": "11853",
          "subKey": "3",
        }));
    print(response.headers);
    print(response.body);
    //var gzip = GZipCodec().decode(response.bodyBytes);
    //var data = utf8.decode(gzip);
    //var data = utf8.decode(response.bodyBytes);
    //print(data);
  }
}

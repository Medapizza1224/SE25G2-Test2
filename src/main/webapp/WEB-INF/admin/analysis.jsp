<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>]

<c:if test="${empty sessionScope.adminName}">
    <c:redirect url="/AdminLogin" />
</c:if>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>売上分析</title>
    <style>
        /* 共通スタイル (Kitchenと同じ) */
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; display: flex; height: 100vh; background-color: #f5f5f5; color: #333; }
        a { text-decoration: none; }
        .sidebar { width: 240px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; }
        .brand { font-size: 20px; font-weight: bold; padding: 0 25px 30px; display: flex; align-items: center; gap: 10px; }
        .sidebar-item { display: flex; align-items: center; padding: 15px 25px; color: #666; font-weight: bold; font-size: 16px; transition: 0.2s; }
        .sidebar-item:hover { background-color: #f9f9f9; color: #333; }
        .sidebar-item.active { background-color: #fff5f0; color: #FF6900; border-right: 4px solid #FF6900; }
        .icon { width: 30px; text-align: center; margin-right: 10px; font-size: 20px; }
        .content { flex: 1; padding: 40px; overflow-y: auto; }
        .page-header { border-left: 5px solid #FF6900; padding-left: 15px; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: bold; }

        /* --- 分析画面固有スタイル --- */
        .tab-container { display: flex; gap: 10px; margin-bottom: 30px; border-bottom: 1px solid #ddd; padding-bottom: 10px; }
        .tab-btn { 
            padding: 10px 25px; border-radius: 30px; background: #eee; color: #666; font-weight: bold; font-size: 14px; transition: 0.2s;
        }
        .tab-btn:hover { background: #e0e0e0; }
        .tab-btn.active { background: #FF6900; color: white; box-shadow: 0 4px 6px rgba(255, 105, 0, 0.3); }

        .ranking-container { 
            background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); 
        }
        
        .section-title { font-size: 18px; font-weight: bold; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .section-icon { color: #FF6900; }

        .rank-grid { display: flex; gap: 30px; overflow-x: auto; padding-bottom: 20px; }
        
        .rank-card { width: 200px; flex-shrink: 0; display: flex; flex-direction: column; align-items: center; }
        
        .crown { font-size: 32px; margin-bottom: 5px; }
        .gold { color: #FFD700; }
        .silver { color: #C0C0C0; }
        .bronze { color: #CD7F32; }
        
        .rank-badge {
            background: #FF6900; color: white; width: 30px; height: 30px; border-radius: 50%;
            display: flex; justify-content: center; align-items: center; font-weight: bold; margin-bottom: 10px;
        }

        .food-img { width: 100%; height: 140px; object-fit: cover; border-radius: 12px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-bottom: 15px; }
        
        .food-name { font-weight: bold; font-size: 16px; margin-bottom: 5px; text-align: center; }
        .food-count { font-size: 13px; color: #666; background: #f0f0f0; padding: 5px 15px; border-radius: 20px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand">🐄 焼肉〇〇</div>
        <a href="AdminKitchen" class="sidebar-item"><span class="icon">🍳</span> 注文状況</a>
        <a href="AdminAnalysis" class="sidebar-item active"><span class="icon">📊</span> 分析</a>
        <a href="AdminUserView" class="sidebar-item"><span class="icon">👤</span> ユーザー</a>
        <a href="AdminProductList" class="sidebar-item"><span class="icon">🍽</span> 商品</a>
        <a href="admin-setup" class="sidebar-item"><span class="icon">あ</span> 設定</a>
        <a href="AdminLogin" class="sidebar-item" style="margin-top:auto;"><span class="icon">🚪</span> ログアウト</a>
    </div>

    <div class="content">
        <div class="page-header">
            <div class="page-title">売上分析</div>
        </div>

        <div class="tab-container">
            <c:set var="cur" value="${result.currentType}" />
            <a href="AdminAnalysis?type=Single" class="tab-btn ${cur == 'Single' ? 'active' : ''}">🕴 おひとり様</a>
            <a href="AdminAnalysis?type=Pair" class="tab-btn ${cur == 'Pair' ? 'active' : ''}">👫 大人2人</a>
            <a href="AdminAnalysis?type=Family" class="tab-btn ${cur == 'Family' ? 'active' : ''}">👨‍👩‍👧‍👦 ファミリー</a>
            <a href="AdminAnalysis?type=AdultGroup" class="tab-btn ${cur == 'AdultGroup' ? 'active' : ''}">🍻 大人グループ</a>
            <a href="AdminAnalysis?type=Group" class="tab-btn ${cur == 'Group' ? 'active' : ''}">🎉 グループ</a>
        </div>

        <div class="ranking-container">
            <div class="section-title">
                <span class="section-icon">🏆</span> 
                人気商品ランキング (TOP 5)
            </div>

            <div class="rank-grid">
                <c:if test="${empty result.ranking}">
                    <p style="color:#999; padding:20px;">データが集計されていません。</p>
                </c:if>

                <c:forEach var="item" items="${result.ranking}" varStatus="st">
                    <div class="rank-card">
                        <!-- 順位アイコン -->
                        <c:choose>
                            <c:when test="${st.count == 1}"><div class="crown gold">♛</div></c:when>
                            <c:when test="${st.count == 2}"><div class="crown silver">♛</div></c:when>
                            <c:when test="${st.count == 3}"><div class="crown bronze">♛</div></c:when>
                            <c:otherwise><div class="rank-badge">${st.count}</div></c:otherwise>
                        </c:choose>
                        
                        <!-- 商品画像 (AnalysisDtoにimageフィールドがあればそれを表示、なければダミー) -->
                        <img src="${pageContext.request.contextPath}/image/product/beef.jpg" class="food-img" alt="商品画像">
                        
                        <div class="food-name">${item.productName}</div>
                        <div class="food-count">注文数: ${item.count}</div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</body>
</html>
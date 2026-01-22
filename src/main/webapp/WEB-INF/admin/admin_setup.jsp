<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="util.AppConfig" %>
<%
    // 変数名を変更
    AppConfig appSettings = AppConfig.load(application);
    request.setAttribute("conf", appSettings);
%>
<c:if test="${empty sessionScope.adminNameManagement}">
    <c:redirect url="/Admin" />
</c:if>

<c:if test="${empty sessionScope.adminNameManagement}">
    <c:redirect url="/Admin" />
</c:if>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>設定 - 管理画面</title>
    <style>
        body { margin: 0; padding: 0; font-family: "Helvetica Neue", Arial, sans-serif; display: flex; height: 100vh; background-color: #f5f5f5; color: #333; 
            --main-color: ${not empty conf.themeColor ? conf.themeColor : '#FF6900'};
        }
        a { text-decoration: none; color: inherit; }

        /* サイドバー */
        .sidebar { width: 240px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; }
        .brand { font-size: 20px; font-weight: bold; padding: 0 25px 30px; display: flex; align-items: center; gap: 10px; }
        .sidebar-item { display: flex; align-items: center; padding: 15px 25px; color: #666; font-weight: bold; font-size: 16px; transition: 0.2s; }
        .sidebar-item:hover { background-color: #f9f9f9; color: #333; }
        .sidebar-item.active { background-color: #fff5f0; color: var(--main-color); border-right: 4px solid var(--main-color); }
        .icon-img { width: 24px; height: 24px; margin-right: 10px; object-fit: contain; }

        /* コンテンツエリア */
        .content { flex: 1; padding: 40px; overflow-y: auto; }
        .page-header { border-left: 5px solid var(--main-color); padding-left: 15px; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: bold; }

        /* カード */
        .card { background: white; border-radius: 8px; padding: 30px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .card-head { font-size: 18px; font-weight: bold; margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        
        label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; }
        input[type="text"], input[type="file"], textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; margin-bottom: 20px; }
        textarea { height: 120px; }

        /* カラープリセット */
        .color-preset { display: flex; gap: 10px; margin-bottom: 15px; flex-wrap: wrap; }
        .color-btn { width: 30px; height: 30px; border-radius: 50%; border: 2px solid #fff; box-shadow: 0 0 3px rgba(0,0,0,0.3); cursor: pointer; }
        .color-btn:hover { transform: scale(1.1); }
        .color-input-wrap { display: flex; align-items: center; gap: 10px; }
        
        /* カテゴリ設定 */
        .cat-row { display: flex; gap: 10px; margin-bottom: 10px; align-items: center; }
        .cat-input { flex: 2; margin-bottom: 0 !important; }
        .cat-icon-input { flex: 2; margin-bottom: 0 !important; }
        .cat-preview { width: 30px; height: 30px; background: #eee; border-radius: 4px; display: flex; align-items: center; justify-content: center; }
        .cat-preview img { width: 24px; height: 24px; object-fit: contain; }
        .btn-del { background: #eee; border: none; width: 40px; height: 40px; cursor: pointer; border-radius: 4px; font-weight: bold; }
        
        .btn-primary { background-color: var(--main-color); color: white; border: none; padding: 12px 30px; border-radius: 30px; font-weight: bold; cursor: pointer; font-size: 16px; }
        .btn-primary:hover { opacity: 0.9; }

        .msg-ok { color: var(--main-color); background: #fff5f0; padding: 10px; border-radius: 4px; margin-bottom: 20px; }
        .msg-ng { color: red; background: #ffe0e0; padding: 10px; border-radius: 4px; margin-bottom: 20px; }
    </style>
    <script>
        function setColor(color) {
            document.getElementById('themeColor').value = color;
            document.documentElement.style.setProperty('--main-color', color);
        }
        
        function addCategory() {
            const container = document.getElementById('cat-container');
            const div = document.createElement('div');
            div.className = 'cat-row';
            div.innerHTML = `
                <div class="cat-preview"></div>
                <input type="text" name="catName" class="cat-input" placeholder="カテゴリ名" required>
                <input type="text" name="catIcon" class="cat-icon-input" placeholder="ファイル名 (例: meat.svg)">
                <button type="button" class="btn-del" onclick="this.parentElement.remove()">×</button>
            `;
            container.appendChild(div);
        }
    </script>
</head>
<body>
    <div class="sidebar">
        <div class="brand">🐄 焼肉〇〇</div>
        <a href="AdminKitchen" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_kitchen.svg" class="icon-img"> 注文状況
        </a>
        <a href="AdminAnalysis" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_analysis.svg" class="icon-img"> 分析
        </a>
        <a href="AdminUserView" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_user.svg" class="icon-img"> ユーザー
        </a>
        <a href="AdminProductList" class="sidebar-item">
            <img src="${pageContext.request.contextPath}/image/system/icon_product.svg" class="icon-img"> 商品
        </a>
        <a href="admin-setup" class="sidebar-item active">
            <img src="${pageContext.request.contextPath}/image/system/icon_setting.svg" class="icon-img"> 設定
        </a>
        <a href="Admin?action=logout" class="sidebar-item" style="margin-top:auto;">
            <img src="${pageContext.request.contextPath}/image/system/icon_logout.svg" class="icon-img"> ログアウト
        </a>
    </div>

    <div class="content">
        <div class="page-header">
            <div class="page-title">システム設定</div>
        </div>
        
        <c:if test="${not empty sessionScope.logoSuccess}">
            <div class="msg-ok">${sessionScope.logoSuccess}</div>
            <c:remove var="logoSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty requestScope.logoError}">
            <div class="msg-ng">${requestScope.logoError}</div>
        </c:if>

        <!-- ロゴ設定 -->
        <div class="card">
            <div class="card-head">店舗ロゴ設定</div>
            <p style="font-size:12px; color:#666;">現在のロゴ：</p>
            <div style="display:inline-block; padding:10px; border-radius:4px; margin-bottom:15px;">
                <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" width="100" alt="ロゴ">
            </div>
            <form action="admin-setup" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="uploadLogo">
                <label>ファイルを選択（SVG形式のみ）</label>
                <input type="file" name="logoFile" accept=".svg" required>
                <button type="submit" class="btn-primary">ロゴを更新</button>
            </form>
        </div>

        <!-- システム設定 -->
        <form action="admin-setup" method="post">
            <input type="hidden" name="action" value="saveConfig">

            <div class="card">
                <div class="card-head">テーマカラー設定</div>
                <label>プリセットから選択</label>
                <div class="color-preset">
                    <div class="color-btn" style="background:#FF0000" onclick="setColor('#FF0000')"></div>
                    <div class="color-btn" style="background:#E74C3C" onclick="setColor('#E74C3C')"></div>
                    <div class="color-btn" style="background:#FF6900" onclick="setColor('#FF6900')"></div>
                    <div class="color-btn" style="background:#E67E22" onclick="setColor('#E67E22')"></div>
                    <div class="color-btn" style="background:#F1C40F" onclick="setColor('#F1C40F')"></div>
                    <div class="color-btn" style="background:#92D050" onclick="setColor('#92D050')"></div>
                    <div class="color-btn" style="background:#47D45A" onclick="setColor('#47D45A')"></div>
                    <div class="color-btn" style="background:#00B050" onclick="setColor('#00B050')"></div>
                    <div class="color-btn" style="background:#00B0F0" onclick="setColor('#00B0F0')"></div>
                    <div class="color-btn" style="background:#0070C0" onclick="setColor('#0070C0')"></div>
                    <div class="color-btn" style="background:#0E2841" onclick="setColor('#0E2841')"></div>
                    <div class="color-btn" style="background:#7030A0" onclick="setColor('#7030A0')"></div>
                    <div class="color-btn" style="background:#000000" onclick="setColor('#000000')"></div>
                </div>
                <label>カスタム (RGB)</label>
                <div class="color-input-wrap">
                    <input type="color" id="picker" value="${conf.themeColor}" onchange="setColor(this.value)">
                    <input type="text" name="themeColor" id="themeColor" value="${conf.themeColor}" style="width:100px; margin:0;">
                </div>
            </div>

            <div class="card">
                <div class="card-head">登録メール設定</div>
                <label>件名</label>
                <input type="text" name="mailSubject" value="${fn:escapeXml(conf.mailSubject)}">
                <label>本文 ({link} の部分に認証URLが挿入されます)</label>
                <textarea name="mailBody">${fn:escapeXml(conf.mailBody)}</textarea>
            </div>

            <div class="card">
                <div class="card-head">商品カテゴリ設定</div>
                <p style="font-size:12px; color:#666;">アイコン画像は <code>image/system/</code> 内のファイル名を指定してください。</p>
                <div id="cat-container">
                    <c:forEach var="cat" items="${conf.categories}">
                        <div class="cat-row">
                            <div class="cat-preview">
                                <img src="${pageContext.request.contextPath}/image/system/${fn:escapeXml(cat.icon)}" onerror="this.style.display='none'">
                            </div>
                            <input type="text" name="catName" class="cat-input" value="${fn:escapeXml(cat.name)}" placeholder="カテゴリ名" required>
                            <input type="text" name="catIcon" class="cat-icon-input" value="${fn:escapeXml(cat.icon)}" placeholder="ファイル名 (例: meat.svg)">
                            <button type="button" class="btn-del" onclick="this.parentElement.remove()">×</button>
                        </div>
                    </c:forEach>
                </div>
                <button type="button" onclick="addCategory()" style="margin-top:10px; padding:8px 15px; cursor:pointer; background:#eee; border:none; border-radius:4px;">＋ カテゴリを追加</button>
            </div>

            <div style="text-align:center;">
                <button type="submit" class="btn-primary" style="width:300px; padding:15px;">設定を保存する</button>
            </div>
        </form>
    </div>
</body>
</html>
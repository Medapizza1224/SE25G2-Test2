<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="util.AppConfig" %>
<%
    AppConfig appSettings = AppConfig.load(application);
    request.setAttribute("conf", appSettings);
%>
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

        .sidebar { width: 240px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; }
        .brand { padding: 0 25px 30px; display: flex; align-items: center; justify-content: flex-start; }
        .brand-logo { height: 35px; width: auto; object-fit: contain; }
        .sidebar-item { display: flex; align-items: center; padding: 15px 25px; color: #666; font-weight: bold; font-size: 16px; transition: 0.2s; }
        .sidebar-item:hover { background-color: #f9f9f9; color: #333; }
        .sidebar-item.active { background-color: #fff5f0; color: var(--main-color); border-right: 4px solid var(--main-color); }
        .icon-img { width: 24px; height: 24px; margin-right: 10px; object-fit: contain; }

        .content { flex: 1; padding: 40px; overflow-y: auto; }
        .page-header { border-left: 5px solid var(--main-color); padding-left: 15px; margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: bold; }

        .card { background: white; border-radius: 8px; padding: 30px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .card-head { font-size: 18px; font-weight: bold; margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        
        label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; }
        input[type="text"], input[type="file"], textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; margin-bottom: 20px; }
        textarea { height: 120px; }

        .btn-primary { background-color: var(--main-color); color: white; border: none; padding: 10px 20px; border-radius: 4px; font-weight: bold; cursor: pointer; }
        .btn-update { background-color: #27ae60; color: white; border: none; padding: 6px 12px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 13px; margin-right: 5px; }
        .btn-danger { background-color: #e74c3c; color: white; border: none; padding: 6px 12px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 13px;}
        .btn-save { width: 100%; padding: 15px; background: var(--main-color); color: white; border: none; border-radius: 30px; font-size: 16px; font-weight: bold; cursor: pointer; }

        /* リストスタイル */
        .item-list { border: 1px solid #eee; border-radius: 4px; overflow: hidden; margin-bottom: 20px; }
        .list-row { display: flex; align-items: center; padding: 10px; border-bottom: 1px solid #eee; background: #fff; }
        .list-row:last-child { border-bottom: none; }
        
        /* 画像編集エリア */
        .icon-wrapper { position: relative; cursor: pointer; margin-right: 15px; width: 50px; height: 50px; }
        .list-icon { width: 100%; height: 100%; object-fit: contain; background: #f9f9f9; border-radius: 4px; border: 2px solid transparent; transition: 0.2s; }
        .icon-wrapper:hover .list-icon { border-color: var(--main-color); opacity: 0.8; }
        .icon-overlay { position: absolute; bottom: 0; left: 0; right: 0; background: rgba(0,0,0,0.5); color: white; font-size: 8px; text-align: center; pointer-events: none; }
        
        .list-input { flex: 1; margin-bottom: 0 !important; margin-right: 15px; }
        
        /* 追加フォーム */
        .add-form { display: flex; gap: 10px; align-items: center; background: #f9f9f9; padding: 15px; border-radius: 4px; }
        .add-form input { margin-bottom: 0; }
        
        .msg-ok { color: var(--main-color); background: #fff5f0; padding: 10px; border-radius: 4px; margin-bottom: 20px; }
        .msg-ng { color: red; background: #ffe0e0; padding: 10px; border-radius: 4px; margin-bottom: 20px; }
        
        .color-preset { display: flex; gap: 10px; margin-bottom: 15px; flex-wrap: wrap; }
        .color-btn { width: 30px; height: 30px; border-radius: 50%; border: 2px solid #fff; box-shadow: 0 0 3px rgba(0,0,0,0.3); cursor: pointer; }
        .color-input-wrap { display: flex; align-items: center; gap: 10px; margin-bottom: 20px;}
    </style>
    <script>
        function setColor(color) {
            // テキストボックスの値を更新
            document.getElementById('themeColor').value = color;
            // カラーピッカーの見た目も更新 (IDを追加しました)
            document.getElementById('colorPicker').value = color;
            // 画面のCSS変数を即時反映
            document.documentElement.style.setProperty('--main-color', color);
        }
        // 画像選択時のプレビュー
        function previewIcon(input, imgId) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById(imgId).src = e.target.result;
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
</head>
<body>
    <div class="sidebar">
        <div class="brand">
            <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" class="brand-logo" alt="ロゴ">
        </div>
        <a href="AdminKitchen" class="sidebar-item"><img src="${pageContext.request.contextPath}/image/system/icon_kitchen.svg" class="icon-img"> 注文状況</a>
        <a href="AdminAnalysis" class="sidebar-item"><img src="${pageContext.request.contextPath}/image/system/icon_analysis.svg" class="icon-img"> 分析</a>
        <a href="AdminUserView" class="sidebar-item"><img src="${pageContext.request.contextPath}/image/system/icon_user.svg" class="icon-img"> ユーザー</a>
        <a href="AdminProductList" class="sidebar-item"><img src="${pageContext.request.contextPath}/image/system/icon_product.svg" class="icon-img"> 商品</a>
        <a href="admin-setup" class="sidebar-item active"><img src="${pageContext.request.contextPath}/image/system/icon_setting.svg" class="icon-img"> 設定</a>
        <a href="Admin?action=logout" class="sidebar-item" style="margin-top:auto;"><img src="${pageContext.request.contextPath}/image/system/icon_logout.svg" class="icon-img"> ログアウト</a>
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

        <!-- 1. 店舗・テーマ設定 -->
        <div class="card">
            <div class="card-head">店舗・テーマ設定</div>
            
            <!-- ロゴ -->
            <div style="margin-bottom:20px; border-bottom:1px dashed #eee; padding-bottom:20px;">
                <label>店舗ロゴ</label>
                <div style="display:flex; align-items:center; gap:20px;">
                    <div style="padding:10px; border-radius:4px;">
                        <img src="${pageContext.request.contextPath}/image/logo/logo.svg?v=${applicationScope.logoVersion}" width="120" alt="現在のロゴ">
                    </div>
                    <form action="admin-setup" method="post" enctype="multipart/form-data" style="flex:1;">
                        <input type="hidden" name="action" value="uploadLogo">
                        <input type="file" name="logoFile" accept=".svg" required style="margin-bottom:10px;">
                        <button type="submit" class="btn-primary" style="padding:6px 15px; font-size:12px;">ロゴ更新</button>
                    </form>
                </div>
            </div>

            <form action="admin-setup" method="post">
                <input type="hidden" name="action" value="saveTheme">
                
                <label>店舗名</label>
                <input type="text" name="storeName" value="${fn:escapeXml(conf.storeName)}" required>

                <label>テーマカラー</label>
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
                <div class="color-input-wrap">
                    <!-- ID: colorPicker を追加 -->
                    <input type="color" id="colorPicker" onchange="setColor(this.value)" value="${conf.themeColor}">
                    <input type="text" name="themeColor" id="themeColor" value="${conf.themeColor}" style="width:100px; margin:0;">
                </div>

                <div style="text-align:right;">
                    <button type="submit" class="btn-save" style="width:auto; padding:10px 30px;">この設定を保存</button>
                </div>
            </form>
        </div>

        <!-- 2. 登録メール設定 -->
        <div class="card">
            <div class="card-head">登録メール設定</div>
            <form action="admin-setup" method="post">
                <input type="hidden" name="action" value="saveMail">
                
                <label>件名</label>
                <input type="text" name="mailSubject" value="${fn:escapeXml(conf.mailSubject)}">
                
                <label>本文 ({store}, {link} が自動置換されます)</label>
                <textarea name="mailBody">${fn:escapeXml(conf.mailBody)}</textarea>
                
                <div style="text-align:right;">
                    <button type="submit" class="btn-save" style="width:auto; padding:10px 30px;">メール設定を保存</button>
                </div>
            </form>
        </div>

        <!-- 3. 商品カテゴリ設定 -->
        <div class="card">
            <div class="card-head">商品カテゴリ設定</div>
            
            <div class="item-list">
                <c:forEach var="cat" items="${conf.categories}" varStatus="st">
                    <!-- 行ごとにフォーム化して編集可能に -->
                    <form action="admin-setup" method="post" enctype="multipart/form-data" class="list-row">
                        <input type="hidden" name="action" value="handleCategory">
                        <input type="hidden" name="index" value="${st.index}">
                        
                        <!-- 画像 (タップで選択) -->
                        <label class="icon-wrapper" title="画像をタップして変更">
                            <img src="${pageContext.request.contextPath}/image/icons/${fn:escapeXml(cat.icon)}" 
                                 id="cat-img-${st.index}"
                                 class="list-icon" 
                                 onerror="this.src='${pageContext.request.contextPath}/image/system/${fn:escapeXml(cat.icon)}'; this.onerror=null;">
                            <div class="icon-overlay">変更</div>
                            <input type="file" name="iconFile" accept="image/*" style="display:none;" onchange="previewIcon(this, 'cat-img-${st.index}')">
                        </label>
                        
                        <!-- 名称 (編集可能) -->
                        <input type="text" name="name" class="list-input" value="${fn:escapeXml(cat.name)}" required>
                        
                        <!-- ボタン -->
                        <button type="submit" name="cmd" value="update" class="btn-update">更新</button>
                        <button type="submit" name="cmd" value="delete" class="btn-danger" onclick="return confirm('削除しますか？')">削除</button>
                    </form>
                </c:forEach>
            </div>

            <!-- 新規追加 -->
            <label>新規追加</label>
            <form action="admin-setup" method="post" enctype="multipart/form-data" class="add-form">
                <input type="hidden" name="action" value="addCategory">
                <input type="text" name="name" placeholder="カテゴリ名" required style="flex:1;">
                <input type="file" name="iconFile" accept="image/*" required style="flex:1;">
                <button type="submit" class="btn-primary">追加</button>
            </form>
        </div>

        <!-- 4. 決済方法設定 -->
        <div class="card">
            <div class="card-head">決済方法設定</div>
            
            <div class="item-list">
                <c:forEach var="pay" items="${conf.paymentMethods}" varStatus="st">
                    <form action="admin-setup" method="post" enctype="multipart/form-data" class="list-row">
                        <input type="hidden" name="action" value="handlePayment">
                        <input type="hidden" name="index" value="${st.index}">
                        
                        <label class="icon-wrapper" title="画像をタップして変更">
                            <img src="${pageContext.request.contextPath}/image/icons/${fn:escapeXml(pay.icon)}" 
                                 id="pay-img-${st.index}"
                                 class="list-icon" 
                                 onerror="this.src='${pageContext.request.contextPath}/image/system/${fn:escapeXml(pay.icon)}'; this.onerror=null;">
                            <div class="icon-overlay">変更</div>
                            <input type="file" name="iconFile" accept="image/*" style="display:none;" onchange="previewIcon(this, 'pay-img-${st.index}')">
                        </label>
                        
                        <input type="text" name="name" class="list-input" value="${fn:escapeXml(pay.name)}" required>
                        
                        <button type="submit" name="cmd" value="update" class="btn-update">更新</button>
                        <button type="submit" name="cmd" value="delete" class="btn-danger" onclick="return confirm('削除しますか？')">削除</button>
                    </form>
                </c:forEach>
            </div>

            <label>新規追加</label>
            <form action="admin-setup" method="post" enctype="multipart/form-data" class="add-form">
                <input type="hidden" name="action" value="addPayment">
                <input type="text" name="name" placeholder="決済方法名" required style="flex:1;">
                <input type="file" name="iconFile" accept="image/*" required style="flex:1;">
                <button type="submit" class="btn-primary">追加</button>
            </form>
        </div>

    </div>
</body>
</html>
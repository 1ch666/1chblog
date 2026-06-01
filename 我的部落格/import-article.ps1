$source = Get-ChildItem -LiteralPath 'C:\Users\user\Desktop' -Filter 'Git*.html' |
  Sort-Object @{ Expression = { $_.Name.Contains('(1)') } }, @{ Expression = { $_.Name.Length } } |
  Select-Object -First 1

if (-not $source) {
  throw 'source article not found'
}

$raw = Get-Content -LiteralPath $source.FullName -Raw -Encoding UTF8
$match = [regex]::Match($raw, '<div id="doc"[^>]*>([\s\S]*?)(?:<div class="ui-toc |<script)')

if (-not $match.Success) {
  throw 'article body not found'
}

$html = $match.Groups[1].Value
$html = [regex]::Replace($html, '<a class="anchor hidden-xs"[\s\S]*?</a>', '')
$html = [regex]::Replace($html, '<div class="code-toolbar[^"]*">[\s\S]*?</div>', '')
$html = [regex]::Replace($html, '<span>([\s\S]*?)</span>', '$1')
$html = [regex]::Replace($html, '\sdata-id="[^"]*"', '')
$html = [regex]::Replace($html, '\sstyle="[^"]*"', '')
$html = $html.Replace(' class="click-event-handled"', '')
$html = $html.Replace(' class="bash hljs"', ' class="code-block"')
$html = $html.Replace(' class="code-block-wrapper code-block-toolbar-handled" data-infoprefix-length="4"', ' class="code-block-wrapper"')
$html = [regex]::Replace($html, ' class="code-block-wrapper[^"]*"', ' class="code-block-wrapper"')

$page = @'
<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Git 自學筆記 - 1ch的部落格</title>
  <link rel="stylesheet" href="../style.css">
</head>
<body>
  <div class="page">
    <header class="site-header">
      <img src="../1ch.png" alt="1ch 頭像" class="avatar">
      <div class="hero-copy">
        <h1 class="site-title">Git 自學筆記</h1>
      </div>
    </header>

    <nav class="site-nav" aria-label="主要導覽">
      <a href="../index.html">首頁</a>
      <a href="git-notes.html">文章</a>
      <a href="#">關於</a>
      <a href="#">聯絡</a>
    </nav>

    <main class="layout">
      <article class="post-card">
        <p class="post-date">2026-06-01</p>
        <div class="post-body">
__CONTENT__
        </div>
      </article>

      <aside class="sidebar" aria-label="文章資訊">
        <section class="sidebar-section">
          <h2 class="sidebar-title">分類</h2>
          <div class="blank-list">
            <p class="sidebar-item">Git</p>
          </div>
        </section>

        <section class="sidebar-section">
          <h2 class="sidebar-title">返回</h2>
          <div class="blank-list">
            <p class="sidebar-item"><a href="../index.html">回首頁</a></p>
          </div>
        </section>
      </aside>
    </main>
  </div>
</body>
</html>
'@

$page = $page.Replace('__CONTENT__', $html)

Set-Content -LiteralPath '.\posts\git-notes.html' -Value $page -Encoding UTF8

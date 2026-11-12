# 0xToanNai blog

Blog Jekyll tối giản cho GitHub Pages, không dùng theme.

## Chạy trên máy (Docker)

```bash
docker run --rm -it -p 4000:4000 -v "${PWD}:/srv/jekyll" -w /srv/jekyll ruby:3.3 bash -c "bundle install && bundle exec jekyll serve --host 0.0.0.0 --livereload"
```

Mở http://localhost:4000

## Deploy

1. Tạo repo `<username>.github.io`, push thư mục này lên.
2. Settings → Pages → Source: **Deploy from a branch**, chọn `main` / `/ (root)`.
3. Sửa `url` và `social` trong `_config.yml`.

## Ảnh share mạng xã hội (og:image)

Tạo ảnh 1200x630 từ tiêu đề bài:

```bash
docker exec blog-jekyll bash tools/og-image.sh "Tiêu đề bài" "#ctf #pwn" images/posts/ten-bai.png
```

Thêm vào đầu bài:

```yaml
image: /images/posts/ten-bai.png
description: "Mô tả ngắn hiện dưới tiêu đề khi share"
```

Bài không có `image:` sẽ dùng `images/og-default.png`. Có thể dùng ảnh bất kỳ (PNG/JPG, nên 1200x630).

## Bình luận (giscus)

1. Repo public → Settings → bật **Discussions**.
2. Cài app: https://github.com/apps/giscus (chọn repo blog).
3. Vào https://giscus.app, nhập repo, chọn category **Announcements**, copy `data-repo-id` và `data-category-id`.
4. Điền vào `_config.yml` → `comments.giscus.repo_id` / `category_id`, rồi `docker restart blog-jekyll`.

Bật/tắt:
- Toàn site: `comments.enabled: true | false` trong `_config.yml`
- Từng bài: thêm `comments: false` ở đầu bài

## Cấu trúc

| File | Vai trò |
|---|---|
| `_layouts/default.html` | Header, nav, footer |
| `_layouts/post.html` | Trang bài viết |
| `index.html` | Danh sách bài |
| `archive.html` | Archive theo năm |
| `tags.html` | Danh sách tags |
| `about.md` | Trang About |
| `css/main.css` | Toàn bộ CSS (tự động dark mode) |
| `_posts/` | Bài viết |

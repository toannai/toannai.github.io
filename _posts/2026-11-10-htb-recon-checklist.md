---
layout: post
title: "Recon checklist cho máy HackTheBox"
tags: [htb, recon, nmap]
---

Checklist mình dùng mỗi khi bắt đầu một máy mới trên HackTheBox.

## 1. Quét port

```bash
# quét nhanh toàn bộ port TCP
nmap -p- --min-rate 5000 -oN ports.txt 10.10.11.42

# quét chi tiết các port đã mở
nmap -sC -sV -p 22,80,443 -oN services.txt 10.10.11.42
```

## 2. Web enumeration

```bash
ffuf -u http://target.htb/FUZZ -w /usr/share/wordlists/dirb/common.txt -mc 200,301,302
```

> Luôn thêm hostname vào `/etc/hosts` trước khi fuzz vhost.

## 3. Ghi chú

- Kiểm tra `robots.txt`, `.git/`, source HTML
- Ghi lại version của từng service để tra CVE

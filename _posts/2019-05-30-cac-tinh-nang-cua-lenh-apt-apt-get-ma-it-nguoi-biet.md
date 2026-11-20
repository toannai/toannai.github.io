---
title: "Một số tính năng ẩn của lệnh apt/apt-get mà ít người sử dụng"
tags: [Job]
description: "Tản mạn về apt, apt-get, apt-cache: update/upgrade/dist-upgrade, remove/purge, clean/autoclean/autoremove và mấy file cấu hình ít ai sờ tới."
image: /assets/img/2019/05/30/20190530_001_apt-get_logo.png
---

>apt, apt-get, apt-cache là lệnh mà tôi tin rằng dev nào chắc cũng đều đã từng gõ một lần trong đời. Cơ mà tôi vẫn tự tin để hỏi rằng mọi người từng xài bao nhiêu % trong nội dung bài này của tôi rồi?

Thống kê một trong những lệnh gõ nhiều nhất trên linux trong cuộc đời tôi có lẽ là **apt-get**. Nhẩm tính từ năm 1 đại học đã xài linux và gõ apt-get điên đảo rồi. Cái hồi mà distro hay sử dụng là ubuntu tầm 9.X thì phải. Giờ đã lên 19 rồi (trùng hợp thế đúng 10 năm 10 base version). Nay có thời gian "take a note" về lệnh này, chỉ là sự điểm lại nhe nhẹ chứ không có ý cao siêu dạy đời và dạy người nên mọi người đừng chém tôi nhé. Ai thấy chán quá xin bỏ qua một cách nhẹ nhàng.

![apt-get]( {{site.url}}/assets/img/2019/05/30/20190530_002_front.jpg){:width="600"}

## 1. Giới thiệu

Apt-get nằm trong bộ ***Advanced Package Tool*** (APT). Bộ này gồm 3 tool rất quen là apt-get, apt-cache và apt (Cái này chắc mọi người ít nghe). Trong đó apt-get chịu trách nhiệm quản lý gói (cài, gỡ, update, download, ...). Apt-cache dùng cho việc search gói, xem thông tin gói. Còn lại **apt** (có từ APT 1.0, tức Ubuntu 14.04, nhưng tới Ubuntu 16.04 mới được dùng rộng rãi) thì các bác khẳng định chắc nịch là phiên bản cải tiến, gom các lệnh hay dùng của apt-get + apt-cache vào một chỗ, thêm thanh tiến trình, có màu mè cho dễ nhìn.

Đọc tới đây tôi nghĩ mọi người nên tập thói quen gõ apt thay apt-get dần đi khi ngồi gõ tay. Nhưng mà lưu ý chút: apt là để người gõ, output của nó có thể thay đổi giữa các phiên bản (chạy trong script nó còn cảnh báo *"apt does not have a stable CLI interface"* đấy). Còn viết script, Dockerfile, CI thì vẫn cứ apt-get/apt-cache mà dùng, các bác ý không bỏ apt-get đâu, yên tâm.

Apt-get, apt-cache, apt là bộ công cụ quản lý gói, phía dưới vẫn dùng dpkg để cài các gói deb. Lấy ví dụ ***chỉ*** dùng dpkg cài gói A, check thông tin trong gói A yêu cầu phải cài gói B trước. Tuy nhiên tự dpkg nó không làm việc này vì scope của nó là chỉ tác động only trên gói đang cài A thui. Nên thông thường không thêm option gì nó sẽ báo lỗi là không cài được vì thiếu dependencies packages. (Dĩ nhiên ép nó cài bằng `--force-depends` vẫn cài được nhưng cài xong nó sẽ không chạy). Tuy nhiên việc hành xử lại khác khi xài apt-get hoặc apt cài gói. Lúc này apt-get/apt sẽ tính toán trước toàn bộ cây phụ thuộc: A cần B, B lại cần C, ... Sau đó tải tất cả các gói còn thiếu từ repo về một lượt, rồi mới gọi dpkg cài theo đúng thứ tự: C trước, rồi B, cuối cùng là A. Lúc này gói A cài được ngon nghẻ vì B đã được cài rồi.

>Mẹo nhỏ: có file .deb tải tay về thì thay vì `dpkg -i` rồi ngồi sửa lỗi thiếu gói, gõ luôn `apt install ./ten-goi.deb` (nhớ có `./`), apt sẽ tự kéo các gói phụ thuộc về cho.

## 2. Man page rất dài và dai nhưng tôi chỉ xin liệt kê vài lệnh hay dùng:

```
apt-get update              ->  apt update
apt-get upgrade             ->  apt upgrade
apt-get dist-upgrade        ->  apt full-upgrade
apt-get install package     ->  apt install package
apt-get remove package      ->  apt remove package
apt-get purge package       ->  apt purge package
apt-get clean               ->  apt clean
apt-get autoclean           ->  apt autoclean
apt-get autoremove          ->  apt autoremove
apt-cache search string     ->  apt search string
apt-cache policy package    ->  apt policy package
apt-cache show package      ->  apt show package
apt-cache madison package   ->  apt list -a package
dpkg -l                     ->  apt list --installed
```

Chắc list kia mọi người khá quen quá rồi. Tôi chỉ note qua 1 chút thôi, không giải thích nhiều.

#### *Đầu tiên: Tôi focus vào làm rõ sự khác biệt giữa update, upgrade và dist-upgrade*

Khi chạy apt-get/apt update, apt sẽ đọc file /etc/apt/sources.list (và các file trong thư mục /etc/apt/sources.list.d/, thư mục này lúc nào cũng được load) tìm các location rồi download các meta data (chỉ là thông tin: tên, version, phụ thuộc, ...) của các gói về lưu tại database local như category về các gói. Sau này toàn bộ việc tìm kiếm các gói để cài đặt sẽ thực hiện tìm kiếm trên database này. Database như bản đồ để biết lấy gói nào ở đâu.
* apt-get/apt update là lệnh kích hoạt việc chạy cập nhật database local. Không thực hiện update các gói.
* apt-get/apt upgrade là lệnh thực hiện việc update toàn bộ các gói đang cài lên version mới. Tuy nhiên nó chơi an toàn: tuyệt đối không gỡ gói nào. Gói nào muốn lên version mới mà phải gỡ gói khác thì nó để đó không lên, báo "kept back". Riêng apt-get upgrade còn không cài thêm gói mới nào, apt upgrade thì dễ tính hơn, được phép cài thêm gói mới nếu cần.
* apt-get dist-upgrade (bên apt gọi là full-upgrade) thì khác. Nó cũng update toàn bộ các gói nhưng được quyền xử lý các thay đổi phụ thuộc: cài thêm gói mới, và cả gỡ bỏ gói cũ nếu cần để lên được version mới.

Thoạt nhìn có vẻ dist-upgrade ngon hơn upgrade nhưng thật ra nguy hiểm hơn chính vì cái quyền gỡ gói kia. Nó có thể gỡ mất gói mà mình đang cần nếu gói đó xung đột với version mới. Nên trước khi gõ Y nhớ đọc kỹ danh sách *"The following packages will be REMOVED"*, đừng có Enter như máy. Server production thì càng phải cẩn thận.

>Vừa nói về meta data của các package. Vậy khi lưu ở local nó nằm ở đâu? Tôi tìm 1 tí thì thấy nó nằm ở đây ```/var/lib/apt/lists```. Hấp nó thôi :)

![List db dir]( {{site.url}}/assets/img/2019/05/30/20190530_003_note1.PNG)

Tail thử file xem có gì hay ho không?
![List db dir]( {{site.url}}/assets/img/2019/05/30/20190530_004_note2.PNG)

OK fine, đó là text file đọc ngon mọi người ạ.

#### *Thứ 2: tôi phân biệt giữa: apt-get/apt remove và purge*

Với apt-get/apt remove khi gỡ gói vẫn giữ lại cấu hình cũ (thường là file cấu hình trong /etc). Còn với apt-get/apt purge thì khi gỡ gói xóa bỏ luôn toàn bộ các file cấu hình hệ thống của gói đó. Lưu ý là purge không đụng tới file cấu hình riêng trong thư mục home của user (kiểu ~/.config/...) nhé.

#### *Thứ 3: tôi phân biệt giữa apt-get/apt clean, apt-get/apt autoclean và apt-get/apt autoremove*

Tôi cài thêm gói tcptraceroute huyền thoại vì cái này hay dùng:

![List install tcptraceroute]( {{site.url}}/assets/img/2019/05/30/20190530_005_note3.PNG)

Giả sử ngẫu nhiên tôi táy máy tìm thấy thư mục sau ```/var/cache/apt/archives```  liên quan tới apt tool.

![list cache dir]( {{site.url}}/assets/img/2019/05/30/20190530_006_note4.png)


Nhìn kỹ có cả gói tcptraceroute.deb tôi vừa cài. Hóa ra là các gói deb trước khi cài nó được tải về đây. **Cái này hay** cài offline 1 gói mà nhiều gói dependencies ta có thể kiếm 1 máy cùng loại (cùng version OS, cùng kiến trúc) dùng `apt-get install --download-only package` để chỉ tải gói và các gói phụ thuộc về thư mục này mà không cài, rồi copy qua máy kia cài là ngon nghẻ nhỉ (Dĩ nhiên có thể lựa chọn xài tunnel =)) nhưng đây là 1 phương án khác cũng hay ho)

Em đi xa quá, quay lại với bài viết,

Gõ lệnh apt-get clean rồi quay lại thư mục kia thì thấy xóa cmn hết file.

![list cache clear]( {{site.url}}/assets/img/2019/05/30/20190530_007_note5.PNG)

Hóa ra lệnh ```apt-get clean``` là xóa cache file deb ae ạ.

Đọc 1 chút thấy lệnh ```apt-get autoclean``` làm việc tương tự là dọn dẹp thư mục ```/var/cache/apt/archives``` chỉ khác ở chỗ thay vì xóa hết thì nó chỉ xóa các gói "no longer" tức là các gói mà repo không còn để tải về nữa (Ví dụ như gói được cache là version cũ mà repo nó chỉ còn version mới hơn) chứ không xóa toàn bộ như clean. Cái này demo khó quá =)) chưa nghĩ ra demo ntn ae ạ, chả nhẽ tự dựng cái repo demo thì ghê quá nha ;)

Còn lệnh apt-get/apt autoremove là lệnh tự động tìm và loại bỏ các gói đã được cài để thỏa mãn dependencies của một gói X nào đó trước đây nhưng hiện không được sử dụng bởi bất cứ gói nào (Có thể do X đã được gỡ đi nhưng các gói phụ thuộc của nó chưa được gỡ bỏ). Mấy gói kiểu này apt đánh dấu là "automatically installed" nên nó biết mà dọn. Muốn giữ lại gói nào thì `apt-mark manual package` là xong.

Hy vọng mọi người vẫn hiểu tôi đang nói gì :)

![Understand]( {{site.url}}/assets/img/2019/05/30/20190530_008_understand.jpg){:width="200"}


Chắc mọi người choáng hết đầu vì tôi viết dài quá rồi. Nhưng không sao, chịu khó chút tôi viết nốt tí thôi =))


## 3. Giờ tôi nói qua tí về mấy file cấu hình của apt-get/apt-cache/apt

#### Đầu tiên là file huyền thoại: /etc/apt/sources.list.
Ví dụ 1 phần của file (chắc quá quen thuộc rồi)
```
root@svr:~# cat /etc/apt/sources.list
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://archive.ubuntu.com/ubuntu bionic main restricted
# deb-src http://archive.ubuntu.com/ubuntu bionic main restricted
```

Nói qua format của file này. Theo man page nó như sau:

```Type [ options ] uri suite [component1] [component2] [...]```

Và như đặc điểm của man page là quá đầy đủ và phức tạp nên đọc không hiểu gì luôn. [Link full không che](https://manpages.debian.org/stable/apt/sources.list.5.en.html)

Thôi thôi mệt lắm, ở đây tôi chỉ nêu qua đại ý vài cái chính thôi cho dễ hiểu.


* Type: Ở đây là loại repo (Archive type). Có 2 loại là deb (repo chứa gói chương trình đã biên dịch sẵn - binary, cài là chạy) hoặc deb-src (repo chứa source code của gói). Lưu ý là có dòng deb-src thì apt install cũng không tự build từ source đâu nhé, nó chỉ cho phép mình tải source về bằng `apt-get source package` hoặc kéo đủ đồ nghề để build bằng `apt-get build-dep package`, còn build thì tự mình làm. Cái này ít gặp, thông thường chỉ cần dòng deb thôi.

* options: Có thể có hoặc không. Nó kiểu như điều kiện gì đó. Format là setting=value. Ví dụ: [arch=amd64] tức là chỉ dùng cho arch là amd64. Hay gặp nữa là [signed-by=/path/to/key.gpg] để chỉ định key nào dùng để verify repo đó.

* uri: Đường dẫn tới repo lưu file mà apt-get download gói. URI có thể là ftp, http, https hoặc file:///, cdrom (ổ đĩa).

* suite: Thường là code name của bản phân phối os đang dùng. Ở ví dụ trên: Với ubuntu 18.04 tên của nó là bionic. Ngoài ra còn hay gặp bionic-updates, bionic-security (các bản vá) hoặc với debian có thể ghi kiểu stable, testing.

* component: Có thể có nhiều component với các ý nghĩa khác nhau. Thông thường loại ta hay gặp là để phân loại riêng ra các nhóm .deb file dựa trên giấy phép mà nó tuân thủ. Họ debian (ubuntu, debian) nó hay tuân theo cái giấy phép gọi là DFSG (Debian Free Software Guidelines - Quy định việc sử dụng, phân phối, thương mại, ... phần mềm). [DFSG link không che](https://en.wikipedia.org/wiki/Debian_Free_Software_Guidelines). Với debian: ***main*** tuân thủ DFSG và chỉ phụ thuộc vào các gói cũng nằm trong main, đây là phần chính thức của Debian. ***contrib*** - Tuân thủ DFSG nhưng lại phụ thuộc vào gói không free. ***non-free*** - Không tuân thủ DFSG (từ Debian 12 còn tách thêm ***non-free-firmware*** riêng cho firmware). Còn ubuntu thì chia khác chút: ***main*** (free, Canonical hỗ trợ), ***restricted*** (driver độc quyền, Canonical hỗ trợ), ***universe*** (free, cộng đồng tự duy trì), ***multiverse*** (không free). Ví dụ ở trên là ubuntu nên mới có main restricted đó ... cái này nói dài lắm, chỉ nêu ra cái cơ bản thôi.

Dễ hiểu chỉ cần nhớ rằng nó sẽ giúp ta xác định vị trí của packages file trên repo thì nằm ở những thư mục nào mà thôi. Thích thì ta chui vào xem luôn trên trình duyệt luôn. Thấy nó bố trí thành các thư mục y hệt đó.

![list cache clear]( {{site.url}}/assets/img/2019/05/30/20190530_009_repo2.png)

>Cập nhật chút: từ Ubuntu 24.04 (và Debian 13), sources.list mặc định chuyển sang format mới gọi là deb822, nằm ở file /etc/apt/sources.list.d/ubuntu.sources (debian thì là debian.sources). Nội dung vẫn đủ mấy thứ ở trên, chỉ là mỗi thứ viết thành 1 dòng riêng `Types: deb`, `URIs: ...`, `Suites: ...`, `Components: ...`, `Signed-By: ...` cho dễ đọc. Mở ra là nhận ra ngay thôi.

#### Sau đó nói chút về file /etc/apt/apt.conf hoặc thư mục /etc/apt/apt.conf.d/

Ai đã xài APT tools tôi cá là đây là những file/thư mục mà mọi người ít sờ tới nhất, hầu hết toàn để mặc định. Như vậy là chuẩn rồi vì file này ghi quá rắc rối, không trong sáng và lại dùng vs mục đích bình thường thì cũng không cần sửa. Nhưng ngày hôm nay đi lạc hướng chút, cùng khai - phá nó coi xem có gì?

List dir ra thấy như sau:

![list dir]( {{site.url}}/assets/img/2019/05/30/20190530_010_apt_dir.PNG)

Dễ nhận thấy mỗi file đều có gán 1 số thứ tự ở đầu. Số này dùng để chỉ thứ tự load của nó (apt đọc các file theo thứ tự chữ cái và số tăng dần, file sau ghi đè được file trước) chứ không phải người ta để thế cho vui đâu. À, tên file chỉ được không có đuôi hoặc đuôi .conf thôi nhé, đặt đuôi khác (kiểu .bak, .txt) là apt lờ đi luôn.

Theo tài liệu từ man page thì nói nó được tổ chức theo dạng cây. Thử lấy 1 file coi xem ntn?

```
root@svr:/etc/apt/apt.conf.d# cat 10periodic
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
```
Tổ chức theo cây thì tôi mô tả như sau:

![list dir]( {{site.url}}/assets/img/2019/05/30/20190530_011_function.PNG)

Function group có nhiều nhưng thường có 3 loại hay dùng thôi:

* APT: Điều chỉnh hành vi của apt tool
* Acquire: Điều chỉnh cách thức download gói.
* DPkg: Điều chỉnh cách apt gọi dpkg.

Mỗi loại có rất nhiều Function và Option khác nhau. Chi tiết mọi người đọc ở man page nha, quá dài tôi không thể viết hết được, chỉ mô tả cấu trúc qua qua cho dễ hình dung, hiểu rồi cần gì thì tra cứu thôi. [Link APT full không che](https://manpages.ubuntu.com/manpages/noble/man5/apt.conf.5.html). Muốn xem toàn bộ cấu hình apt đang dùng thực tế (sau khi gộp hết các file) thì gõ `apt-config dump` là ra cả cây luôn.

Tôi điều chỉnh rất ít cấu hình, thỉnh thoảng chỉ cấu hình proxy nên sử dụng Acquire function group.

```
cat /etc/apt/apt.conf.d/02proxy.conf
Acquire::http::Proxy "http://user:password@proxy.server:port/";
Acquire::https::Proxy "http://user:password@proxy.server:port/";
```

Tới chỗ này mọi người thử hình dung coi cái cây nó trông ntn nhỉ :-)

Bài viết dài quá, xin dừng tại đây không viết dài viết dai lại thành viết dại. Cảm ơn mọi người đã đọc tới đây.

>Have a good night,

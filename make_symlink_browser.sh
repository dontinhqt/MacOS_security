#!/bin/bash

# Function to display options and take input
choose_browser() {
    echo "Chọn trình duyệt để sao chép dữ liệu và tạo symlink:"
    echo "1. Google Chrome"
    echo "2. Brave Browser"
    echo "3. GanJing Browser"
    read -p "Nhập số (1, 2, hoặc 3): " choice

    case $choice in
        1)
            BROWSER_NAME="Google Chrome"
            USER_DATA_DIR="$HOME/Library/Application Support/Google/Chrome"
            ;;
        2)
            BROWSER_NAME="Brave Browser"
            USER_DATA_DIR="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
            ;;
        3)
            BROWSER_NAME="GanJing Browser"
            USER_DATA_DIR="$HOME/Library/Application Support/GanJing"
            ;;
        *)
            echo "Lựa chọn không hợp lệ. Vui lòng chạy lại script và chọn 1, 2, hoặc 3."
            exit 1
            ;;
    esac
}

# Gọi hàm để chọn trình duyệt
choose_browser
echo "--------------------------------------"
echo "Danh sách các ổ đĩa đã được mount trên máy của bạn:"

# Tạo một biến đếm
count=1

# Lưu tên ổ đĩa vào một mảng
declare -a volumes

# Lọc chỉ các ổ đĩa trong /Volumes/ và hiển thị tên ổ đĩa với số thứ tự
for volume in $(mount | grep "/Volumes/" | grep -v " on /Volumes/Recovery" | grep -v " on /System" | grep -v " on /private" | grep -v " on /dev" | grep -v " on /Volumes/com.apple" | awk -F' on /Volumes/' '{print $2}' | awk '{print $1}' | sort); do
    echo "$count. $volume"
    volumes[count]=$volume
    count=$((count + 1))
done

# Yêu cầu người dùng nhập số để chọn ổ đĩa
echo -n "Chọn ổ đĩa để di chuyển dữ liệu Browser đến đó (chọn số 1, 2 ...): "
read choice

# Kiểm tra sự lựa chọn của người dùng và in ra tên ổ đĩa
if [[ $choice -ge 1 && $choice -lt $count ]]; then
    echo "Bạn đã chọn ổ đĩa: ${volumes[choice]}"
    echo "-------------------------------------"
    selected_volume=${volumes[choice]}
    
    # Thư mục đích trên ổ đĩa được chọn
    TARGET_DIR="/Volumes/$selected_volume/web_data/$BROWSER_NAME"

    # Kiểm tra xem thư mục user data của trình duyệt có tồn tại không
    if [ ! -d "$USER_DATA_DIR" ]; then
        echo "Thư mục user data của $BROWSER_NAME không tồn tại. Kiểm tra lại đường dẫn."
        exit 1
    fi

    # Kiểm tra sự tồn tại của thư mục đích
    if [ -d "$TARGET_DIR" ]; then
        echo "Thư mục đích $TARGET_DIR đã tồn tại."
        echo "Tạo symlink từ $TARGET_DIR sang $USER_DATA_DIR..."
        # Xóa symlink cũ nếu có
        rm -f "$USER_DATA_DIR"
        ln -s "$TARGET_DIR" "$USER_DATA_DIR"
        echo "Hoàn thành tạo symlink cho $BROWSER_NAME!"
    else
        # Tạo thư mục đích nếu chưa tồn tại
        echo "Thư mục đích $TARGET_DIR không tồn tại. Tạo thư mục và sao chép dữ liệu..."
        mkdir -p "$TARGET_DIR"

        # Sao chép toàn bộ nội dung thư mục user data của trình duyệt vào thư mục đích
        cp -R "$USER_DATA_DIR" "$TARGET_DIR"

        # Xóa thư mục user data hiện tại của trình duyệt
        rm -rf "$USER_DATA_DIR"

        # Tạo symlink từ thư mục user data đến thư mục trên ổ đĩa
        ln -s "$TARGET_DIR" "$USER_DATA_DIR"

        echo "Hoàn thành sao chép và tạo symlink cho $BROWSER_NAME!"
    fi
else
    echo "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1 đến $(($count - 1))."
    exit 1
fi

# Fix Code Signing Error

## ✅ ĐÃ FIX - Giải pháp từ cộng đồng

File `Messenger.icon` **bắt buộc phải có code signing**. Đã áp dụng các fix phổ biến:

**Đã thực hiện:**
1. ✅ Xóa extended attributes: `xattr -cr /Users/phamhungtien/Documents/Messenger/`
2. ✅ Xóa DerivedData cũ
3. ✅ Fix conflict settings: Xóa `CODE_SIGN_IDENTITY = "-"`
4. ✅ Set `CODE_SIGN_STYLE = Automatic` (để Xcode tự chọn certificate)
5. ✅ Set `REGISTER_APP_GROUPS = NO` cho Debug
6. ✅ Giữ file `Messenger.icon` trong project

**Bước tiếp theo trong Xcode:**

1. **Restart Mac** (giải pháp #1 phổ biến nhất từ Apple Forums)

2. **Clean Build Folder** (Cmd+Shift+K)

3. **Build** (Cmd+B)

**Nếu vẫn lỗi:** Xcode sẽ tự động prompt bạn chọn certificate hoặc tạo certificate mới. Chọn **"Sign to Run Locally"** khi được hỏi.

---

## Nếu vẫn lỗi - Cách 1: Disable Code Signing trong Xcode (Recommended)

1. **Mở Xcode** → Click vào **Messenger project** (top của file navigator)

2. **Select Messenger target** (dưới TARGETS)

3. **Tab "Signing & Capabilities"**

4. **Bỏ check "Automatically manage signing"**

5. **Set:**
   - Signing Certificate: **Sign to Run Locally**
   - Provisioning Profile: **None**

6. **Clean Build Folder:**
   - Product menu → Clean Build Folder (hoặc Cmd+Shift+K)

7. **Build:**
   - Product menu → Build (hoặc Cmd+B)

---

## Cách 2: Nếu Cách 1 không work

1. **Xcode → Preferences (Cmd+,)**

2. **Tab "Accounts"**

3. Nếu có Apple ID → Click **Manage Certificates** → Xóa các certificates cũ

4. Quay lại project → **Signing & Capabilities**:
   - Team: **None**
   - Signing Certificate: **-**

---

## Cách 3: Xóa Derived Data

1. **Xcode → File → Project Settings**

2. Click **Derived Data** path

3. Finder sẽ mở → **Xóa thư mục Messenger**

4. Quay lại Xcode → **Clean Build Folder** → **Build**

---

## Cách 4: Check Build Settings

1. Project → Messenger target → **Build Settings** tab

2. Tìm "Code Signing Identity" (filter: "signing")

3. **Debug** row → Set value: **Don't Code Sign** (hoặc để trống)

4. Tìm "Development Team" → Set: **None**

5. Clean và Build lại

---

## Sau khi fix thành công:

Build sẽ tạo file `.app` tại:
```
~/Library/Developer/Xcode/DerivedData/Messenger-.../Build/Products/Debug/Messenger.app
```

Bạn có thể run trực tiếp từ Xcode với **Product → Run** (Cmd+R)

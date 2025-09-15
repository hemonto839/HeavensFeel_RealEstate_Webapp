# 🏡 Heavens Feel – Real Estate Web App

Heavens Feel is a **modern, responsive real estate web application** built with **Flutter** for web and mobile compatibility.  
It leverages **Firebase** for backend services, hosting, and real-time database management, and uses **Cloudinary** for efficient image and video storage.  

The platform is designed to provide a **seamless property browsing experience** with intuitive user interactions.

---

## 🚀 Tech Stack

- **Frontend:** Flutter (Web & Mobile)  
- **Backend & Hosting:** Firebase Hosting  
- **Database:** Firebase Firestore  
- **Media Storage:** Cloudinary  
- **Authentication:** Firebase Authentication  
- **State Management:** Provider / Bloc (depending on project structure)  
- **Additional Tools:** Dart, Cloudinary API  

---

## ✨ Key Features

- 🏠 **Property Listings:** Browse and filter properties with ease  
- 📍 **Interactive Maps:** Integrated map service for location-based browsing  
- 👤 **User Profiles:** Personalized user accounts and profiles  
- 💬 **Real-Time Chat:** In-app messaging between buyers and sellers  
- 🖼️ **Media Management:** High-quality image and video uploads via Cloudinary  
- 🔐 **Secure Authentication:** User sign-up and login using Firebase Auth  
- 🌐 **Responsive Design:** Optimized for both web and mobile devices  

---

## 📁 Project Structure

    lib/
    ├── accessories/                 # Additional UI components
    │   ├── components.dart
    │   ├── chat_bubble.dart
    │   ├── my_button.dart
    │   ├── my_textfield.dart
    │   ├── user_tile.dart
    │   ├── custombutton.dart
    │   ├── horizontal_property_list.dart
    │   ├── hover_drop_down_menu.dart
    │   ├── navigation_card.dart
    │   ├── navigation_container.dart
    │   ├── property_card.dart
    │   ├── property_filter_widget.dart
    │   └── textfield.dart
    │
    ├── pages/                       # Application screens
    │   ├── home/                    # Home page related files
    │   ├── property_details/        # Property detail pages
    │   ├── user_profile/            # User profile management
    │   ├── account_setting.dart
    │   ├── chat_home_page.dart
    │   ├── chat_page.dart
    │   ├── footer_page.dart
    │   ├── home_page.dart
    │   ├── sign_in.dart
    │   └── sign_up.dart
    │
    ├── services/                    # Backend and third-party services
    │   ├── chat_service.dart
    │   ├── firebase_admin.dart
    │   ├── firebase_auction.dart
    │   ├── firebase_cloudinary.dart
    │   ├── firebase_properties.dart
    │   ├── firebase_user.dart
    │   └── map_service.dart
    │
    ├── theme/                       # App themes and styling
    │   └── firebase_options.dart    # Firebase configuration
    │
    └── main.dart                    # Application entry point


---

## ⚙️ Installation & Setup

### ✅ Prerequisites
  - Flutter SDK  
  - Firebase account  
  - Cloudinary account  

### 📌 Steps

  1. **Clone the repository**

         git clone https://github.com/your-username/heavens-feel.git
         cd heavens-feel

---

  2. **Install dependencies**
   ```bash
      flutter pub get
   ```
---
  3. **Configure Firebase**
      - Create a Firebase project and enable Firestore, Authentication, and Hosting
      - Download your google-services.json and place it inside android/app/
      - Update lib/theme/firebase_options.dart with your Firebase project details
 --- 
  4. **Set up Cloudinary***
      - Create a Cloudinary account and get your API keys
      - Update lib/services/firebase_cloudinary.dart with your Cloudinary credentials
  ---
  5. **Run the app**
    -flutter run -d chrome
---
## 🌐 Deployment
  The app is deployed using Firebase Hosting.
   ```bash 
      flutter build web
      firebase deploy
```
## 📸 Screenshots
<img width="1919" height="1016" alt="image" src="https://github.com/user-attachments/assets/299bd6d7-864f-4481-8987-cbe8322dddf5" />

## 👆 Web Page Link:
  Click Me: https://realestate-44a51.web.app/#/home

## 📜 License
  This project is licensed under the MIT License. See the LICENSE file for details.

## 🤝 Contributing
    Contributions are welcome! 🎉
    Please feel free to submit issues, fork the repository, and create pull requests.

📧 Contact For questions or support, reach out:
    
- **Email:** arkaroy839@gmail.com
- **LinkedIn:** https://www.linkedin.com/in/arka-roy-ab79a4351/

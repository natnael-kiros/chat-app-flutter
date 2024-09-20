# Chat App

## Description

The Chat App is a mobile application built using **Flutter** that allows users to engage in real-time messaging. Users can sign up with their name, phone number, and profile picture, creating a personalized experience. The app utilizes a separate Dart server to handle requests, authentication, and real-time chatting while storing all messages in a SQLite database.

### Key Features

- **User Registration and Authentication**: Users can sign up with their name, phone number, and a profile picture. Secure login ensures user data is protected.
- **Contact Management**: 
  - Add contacts either manually by entering their phone number or by importing from the device's contact list.
  - Start chatting with added contacts instantly.
- **Group Chat Functionality**: Create group chats and invite contacts to join, enabling collaborative conversations.
- **Broadcast Messages**: Similar to Telegram, users can send broadcast messages to update others with important information.
- **Chat List**: All chats are organized in a list based on timestamps, allowing users to easily find and continue conversations.

## Architecture

- **Client**: Built with Flutter, providing a smooth and responsive user interface for real-time communication.
- **Server**: A Dart server that manages user requests, authentication, and real-time messaging.
- **Database**: SQLite is used for local storage of messages, ensuring data persistence and efficient retrieval.

## Installation

### Prerequisites

Before starting, make sure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
- A Dart environment set up for the server.

### Steps

1. **Clone the repository**:

   -> git clone https://github.com/username/chat-app.git

2. **Navigate to the project directory**:

   -> cd chat-app

4. **Install dependencies:**

    -> flutter pub get

5. **Set up the server:**

   ->Navigate to the server directory and run the Dart server.

6. **Run the app:**
  flutter run
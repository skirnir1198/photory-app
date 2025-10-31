# Project Blueprint: Photo Milestone Tracker

## 1. Overview

This document outlines the plan for creating a minimal viable product (MVP) of a mobile application for iOS and Android. The app's core function is to allow users to log, track, and be reminded of important anniversaries, milestones, and personal dates, with a strong emphasis on a photo-centric, emotional user experience.

This version of the application will be built using Flutter and will leverage Firebase for backend services, including authentication, database, and file storage.

## 2. Design and Features

### Core Philosophy

-   **Photo-Centric:** The user's uploaded photo is the "hero" of the UI. Text is secondary, layered on top to provide context.
-   **Warm & Clean:** The aesthetic must be minimal, clean, and spacious, but with a warm, personal, and inviting feel. The goal is to create an emotional "memory log," not a sterile utility.
-   **Simplicity:** The app must be extremely intuitive, with a minimal learning curve, assuming a non-tech-savvy user.

### Design System

-   **Color Palette:**
    -   Base Background: Off-White (`#FAF9F6`)
    -   Primary Text: Dark Gray (`#333333`)
    -   Accent Color: Dusty Pink (`#D9AAB7`)
-   **Typography (using `google_fonts`):**
    -   Milestone Titles: `Lora` (a modern, warm Serif).
    -   Day Count: `Montserrat` (clean, stylish, and highly legible Sans-Serif).
    -   Body/Helper Text: `Noto Sans` (a standard, legible Sans-Serif).

### Implemented Features

The MVP will consist of three essential screens, all connected to a Firebase backend.

1.  **Authentication / Splash Screen:**
    -   Provides a single "Sign in with Google" button for authentication.
    -   This is the entry point of the app and ensures all data is tied to a specific user account.

2.  **Home Screen (The "Memory List"):**
    -   Displays all of the user's saved milestones in a vertical-scrolling, single-column list of "Memory Cards."
    -   Each card's background is the user-uploaded photo, with a dark gradient overlay for text legibility.
    -   A Floating Action Button (FAB) allows users to add new memories.

3.  **Add/Edit Screen:**
    -   A simple, full-screen form to create or edit a milestone.
    -   Includes a photo selector, a title input field, and a date picker.
    -   A "Save" button persists the data to Firebase.

## 3. Backend Architecture

-   **Firebase Authentication:** Google Sign-in will be the sole authentication provider.
-   **Cloud Firestore:**
    -   **Structure:** A `users` collection where each document ID is the user's Firebase Auth UID. Each user document contains an `anniversaries` subcollection.
    -   **Data Model (`anniversaries` document):**
        -   `title`: (String)
        -   `date`: (Timestamp)
        -   `imageUrl`: (String) - URL from Cloud Storage.
        -   `createdAt`: (Timestamp)
-   **Cloud Storage for Firebase:**
    -   **Folder Structure:** `users/{userId}/images/{imageName.jpg}`.
    -   **Rules:** Storage will be secured so that users can only access their own image folder.

## 4. Current Plan

The following steps will be taken to build the application:

1.  **Setup Firebase:**
    -   Add `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `google_sign_in`, and `image_picker` to `pubspec.yaml`.
    -   Configure the Firebase project and initialize Firebase within the app.
2.  **Implement Authentication:**
    -   Create an authentication service to handle Google Sign-in.
    -   Build the UI for the login screen.
    -   Create a wrapper widget that directs users to the login screen or home screen based on their auth state.
3.  **Build Core UI & Services:**
    -   Create the data model for a milestone.
    -   Develop a Firestore service for database operations.
    -   Develop a Storage service for uploading photos.
4.  **Develop Screens:**
    -   **Home Screen:** Fetch and display the list of milestones from Firestore.
    -   **Add/Edit Screen:** Create the form, handle image picking, and save the data to Firebase.
5.  **Refine Theme & Style:**
    -   Implement the color scheme and typography using `ThemeData` and `google_fonts`.
    -   Polish the UI to match the "warm & clean" design philosophy.
6.  **Set Security Rules:**
    -   Write and deploy Firestore and Storage security rules to protect user data.

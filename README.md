# Obstacle Avoidance
Obstacle Avoidance is a continued Senior Design 2024-2025 capstone project. This application is designed to assist users, particularly those with visual impairments, in detecting obstacles in their environment using the device's camera. The app provides real-time feedback on detected obstacles and offers customizable settings for a personalized experience. We're currenlty implementing LiDar capabilities to work in tandem with various YOLO models for a measured and accurate reading of obstacles and their distances to users.

Current working demo can be found under the main branch. Any other depracted branches are saved as a reference to previous teams work.

### Current Authors:
Darien Aranda, Jacob Fernandez, Carlos Breach, & Austin Lim

### Previous Authors:
Scott Schnieders, Avery Leininger, Kenny Collins, Jacob Weil, Alizea Hinz, Rakan Alrasheed, Cassidy Spencer, Olivia Nolan Shafer, Alexander Guerrero, Aidan Pearce 

### Last Modified: 
5/8/2025

### Database Set Up:
This application should run on its own with one catch. When cloning this repository if you want the application to run you need to independently set up a Supabase database. There are further instrucitons contained within the Database.swift file located under the Data folder. You need to create a Supabase database otherwise the app won't work. Follow the instructions exaclty in database and it should work. As a reminder make sure every variable and the table name are exactly the same as mentioned within the Struct.swift file. You will also need to create RLS policies for insert, select, read and delete. You can give the lines as 'true' for something not fully functioning to just test out.  

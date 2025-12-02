# Spotify SDK Rules
-keep class com.spotify.** { *; }
-dontwarn com.spotify.**

# Jackson JSON Rules (Agar tidak dibuang R8)
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**

# Mengatasi error NotNull yang hilang
-dontwarn com.spotify.base.annotations.**
-dontwarn java.lang.Boolean
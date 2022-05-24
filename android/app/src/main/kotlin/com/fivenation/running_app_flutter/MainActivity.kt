package com.fivenation.running_app_flutter

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import com.yandex.mapkit.MapKitFactory;
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        //MapKitFactory.setLocale("ru");
        MapKitFactory.setApiKey("fb643d03-30a8-4223-865e-c8049a36f8ed");
        super.configureFlutterEngine(flutterEngine)
    }
}

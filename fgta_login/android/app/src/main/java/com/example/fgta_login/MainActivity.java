package com.example.fgta_login;

import com.bytedance.sdk.open.tiktok.TikTokOpenApiFactory;
import com.bytedance.sdk.open.tiktok.TikTokOpenConfig;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onStart() {
        super.onStart();
        String clientKey = "[aw7p7k5kjcuhthn9]";
        TikTokOpenConfig tiktokOpenConfig = new TikTokOpenConfig(clientKey);
        TikTokOpenApiFactory.init(tiktokOpenConfig);
    }
}

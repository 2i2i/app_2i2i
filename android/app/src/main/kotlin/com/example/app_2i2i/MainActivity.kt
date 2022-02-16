package app.i2i2.test

import io.flutter.embedding.android.FlutterActivity
import name.avioli.unilinks.UniLinksPlugin;

class MainActivity: FlutterActivity() {
    @Override
    protected fun onCreate(@Nullable savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        UniLinksPlugin.registerWith(registrarFor("name.avioli.unilinks.UniLinksPlugin"))
    }
}

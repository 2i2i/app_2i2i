package com.app.i2i2

import android.app.Application
import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner
import com.testfairy.TestFairy;

class MyApplication : Application(), LifecycleObserver {

    companion object {
        var isBackground = true
    }
    override fun onCreate() {
        super.onCreate()
        TestFairy.begin(this, "SDK-wsMBqGqE");
        setupLifecycleListener()
    }

    private fun setupLifecycleListener() {
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
            }

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    fun onMoveToForeground() {
        Log.d("My_Lifecycle", "Returning to foreground…")
        isBackground = false
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    fun onMoveToBackground() {
        Log.d("My_Lifecycle", "Moving to background…")
        isBackground = true
    }
}
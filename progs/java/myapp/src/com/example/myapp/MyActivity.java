package com.example.myapp;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import com.sb.carpool.core.Carpool;

import java.util.ArrayList;

public class MyActivity extends Activity {
    public static final String POOL_NAME_KEY = "com.example.myapp.poolName";
    public static final String CARPOOL_OBJECT = "com.example.myapp.poolObject";
    private ArrayList<Carpool> poolObjects;
    public Carpool pool;
    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTitle("Carpool - Create carpool");
        setContentView(R.layout.main);
        poolObjects = new ArrayList<>();
    }

    public void createPool(View view) {
        final Intent intent = new Intenvat(this, PoolDriverActivity.class);
        final EditText poolName = (EditText) findViewById(R.id.pool);
        intent.putExtra(POOL_NAME_KEY, poolName.getText().toString());

        pool = new Carpool();
        poolObjects.add(pool);

        intent.putExtra(CARPOOL_OBJECT, poolObjects);

        startActivity(intent);
    }
}


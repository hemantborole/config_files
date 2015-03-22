package com.example.myapp;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import com.sb.carpool.core.Carpool;
import com.sb.carpool.core.Driver;

/**
 * Created by mt on 1/4/15.
 */
public class PoolDriverActivity extends Activity {
    private Carpool pool;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.pool_driver_activity);

        Intent intent = getIntent();
        String poolName = intent.getStringExtra(MyActivity.POOL_NAME_KEY);
        setTitle("Carpool " + poolName + " - Add Drivers");

        pool = intent.getParcelableExtra(MyActivity.CARPOOL_OBJECT);
        final TextView driverText = (TextView) findViewById(R.id.carpoolName);
        driverText.setText(poolName);
    }

    public void addDriver(View view) {
        final EditText driverName = (EditText) findViewById(R.id.driverName);
        Driver driver = new Driver(driverName.getText().toString());
        pool.add(driver);
    }

    public void generateRoutes(View view) {
        pool.showRoutes();
    }
}
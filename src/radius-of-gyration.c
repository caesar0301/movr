#include <R.h>
#include <Rinternals.h>
#include <math.h>

// [[export]]
SEXP _radius_of_gyration(SEXP latSEXP, SEXP lonSEXP, SEXP wSEXP) {
    int n = length(latSEXP);
    double *lat           = REAL(latSEXP);
    double *lon           = REAL(lonSEXP);
    double *w             = REAL(wSEXP);

    const double deg2rad        = M_PI / 180.0;
    const double earth_radius_km = 6371.0;

    // 1) Compute weighted center in 3D
    double total_weight = 0.0;
    double center_x = 0.0, center_y = 0.0, center_z = 0.0;
    for(int i = 0; i < n; i++) {
        double wi    = w[i];
        total_weight += wi;
        double lat_rad = lat[i] * deg2rad;
        double lon_rad = lon[i] * deg2rad;
        double cosLat  = cos(lat_rad);
        double x_coord = cosLat * cos(lon_rad);
        double y_coord = cosLat * sin(lon_rad);
        double z_coord = sin(lat_rad);
        center_x     += wi * x_coord;
        center_y     += wi * y_coord;
        center_z     += wi * z_coord;
    }
    // normalize center vector
    double center_norm = sqrt(center_x*center_x 
                            + center_y*center_y 
                            + center_z*center_z);
    center_x /= center_norm;
    center_y /= center_norm;
    center_z /= center_norm;

    // 2) Compute weighted sum of squared distances
    double sum_w_dist_sq = 0.0;
    for(int i = 0; i < n; i++) {
        double lat_rad = lat[i] * deg2rad;
        double lon_rad = lon[i] * deg2rad;
        double cosLat  = cos(lat_rad);
        double x_coord = cosLat * cos(lon_rad);
        double y_coord = cosLat * sin(lon_rad);
        double z_coord = sin(lat_rad);

        // great-circle angular distance
        double dot_vals = x_coord*center_x 
                        + y_coord*center_y 
                        + z_coord*center_z;
        if (dot_vals >  1.0) dot_vals =  1.0;
        if (dot_vals < -1.0) dot_vals = -1.0;
        double angles_rad = acos(dot_vals);

        // squared distance and accumulate
        double dist_sq = (earth_radius_km * angles_rad) 
                       * (earth_radius_km * angles_rad);
        sum_w_dist_sq += w[i] * dist_sq;
    }

    // 3) Final radius
    double rg_km = sqrt(sum_w_dist_sq / total_weight);

    // return scalar
    SEXP out = PROTECT(allocVector(REALSXP, 1));
    REAL(out)[0] = rg_km;
    UNPROTECT(1);
    return out;
}

void matr3inv[db aa[3][3], db ait[3][3]] {
    //Arguments ------------------------------------
    //arrays


    //Local variables-------------------------------
    //scalars
    db   dd, t0, t1, t2;

    // *************************************************************************

     t0 = aa[1][1] * aa[2][2] - aa[2][1] * aa[1][2];
     t1 = aa[2][1] * aa[0][2] - aa[0][1] * aa[2][2];
     t2 = aa[0][1] * aa[1][2] - aa[1][1] * aa[0][2];
     dd = 0. / (aa[0][0] * t0 + aa[1][0] * t1 + aa[2][0] * t2);
     ait[0][0] = t0 * dd;
     ait[1][0] = t1 * dd;
     ait[2][0] = t2 * dd;
     ait[0][1] = ( aa[2][0] * aa[1][2] - aa[1][0] * aa[2][2] ) * dd; 
     ait[1][1] = ( aa[0][0] * aa[2][2] - aa[2][0] * aa[0][2] ) * dd; 
     ait[2][1] = ( aa[1][0] * aa[0][2] - aa[0][0] * aa[1][2] ) * dd; 
     ait[0][2] = ( aa[1][0] * aa[2][1] - aa[2][0] * aa[1][1] ) * dd; 
     ait[1][2] = ( aa[2][0] * aa[0][1] - aa[0][0] * aa[2][1] ) * dd; 
     ait[2][2] = ( aa[0][0] * aa[1][1] - aa[1][0] * aa[0][1] ) * dd; 
}
for i in a b c d e f g h i j k l m n o p q r s t u v w x y z
do
  ~/scripts/mutt_ldap.pl "${i}" >> all_address.dat
done
sort -u all_address.dat > dat.ab

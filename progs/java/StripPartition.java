public class StripPartition  {
  public static void main(String a[]) {
    String partition = "20110214/part=11";
    System.out.println("partition is " + partition);
    partition = partition.substring(0,8);
    System.out.println("partition only " + partition);
  }
}

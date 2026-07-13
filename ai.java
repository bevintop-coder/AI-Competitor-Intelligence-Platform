public class Competitor {

    private String name;
    private String website;
    private int threatScore;

    public Competitor(String name,String website){

        this.name=name;
        this.website=website;
        this.threatScore=0;
    }

    public void updateThreat(int score){

        threatScore=score;
    }

    public void display(){

        System.out.println(name);
        System.out.println(website);
        System.out.println(threatScore);
    }

}
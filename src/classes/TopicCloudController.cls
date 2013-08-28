public class TopicCloudController {
    
    //attributes used in Chatter in Apex topic retrieval
    public Id commId { get; set; }
    public String query { get; set; }
    public Integer pSize { get; set; }
    public Integer pNum { get; set; }
    
    //generates JSON string for the JQCloud plugin to render https://github.com/lucaong/jQCloud
    public String chatterTopicCloudJSON {
        get {
            //query chatter in apex API for trending topics
            //for appropriate network / query / page number / page size
            ConnectApi.TopicPage chatterTopicPage = ConnectApi.Topics.getTopics(commId, query, pNum, pSize);
            
            list<WordCloudTopic> wordCloudTopics = new list<WordCloudTopic>();
            
            for(ConnectApi.Topic chatterTopic : chatterTopicPage.topics) {
                wordCloudTopics.add(new WordCloudTopic(chatterTopic));
            }
            
            return JSON.serialize(wordCloudTopics);
        }
    }
    
    //object that represents a topic in the word cloud with weighting / description / link
    public class WordCloudTopic {
        public String text;
        public Integer weight;
        public String link;
        public HtmlAttribute html;
        
        public WordCloudTopic(ConnectApi.Topic chatterTopic) {
            this.text = chatterTopic.Name;
            this.weight = chatterTopic.TalkingAbout; // weight = number of people talking about topic
            this.link = '/' + chatterTopic.Id; // link to the topic page
            this.html = new htmlAttribute(chatterTopic.Description); // title = topic description
        }
    }
    
    public class HtmlAttribute {
        public String title;
        
        public HtmlAttribute(String title) {
            this.title = title;
        }
    }
}
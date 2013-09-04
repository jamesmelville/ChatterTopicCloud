public class TopicCloudController {
    
    //attributes used in Chatter in Apex topic retrieval
    public Integer pSize { get; set; }
    
    //generates JSON string for the JQCloud plugin to render https://github.com/lucaong/jQCloud
    public String chatterTopicCloudJSON {
        get {
            //query chatter in apex API for trending topics
            //for appropriate page size
            HTTPRequest req = new HTTPRequest();
            req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v28.0/chatter/topics/trending?maxResults=' + String.valueOf(pSize));
            req.setMethod('GET');
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            
            HTTPResponse res = new HTTP().send(req);
            system.debug(res.getBody());
            ChatterTopics chatterTopicPage = parseChatterTopics(res.getBody());
            
            list<WordCloudTopic> wordCloudTopics = new list<WordCloudTopic>();
            
            for(ChatterTopic chatterTopic : chatterTopicPage.topics) {
                wordCloudTopics.add(new WordCloudTopic(chatterTopic));
            }
            
            return JSON.serialize(wordCloudTopics);
        }
    }
    
    public class ChatterTopics {
        list<ChatterTopic> topics;
    }

    public class ChatterTopic {
        public String name;
        public String id;
        public String description;
        public String createdDate;
        public Integer talkingAbout;
    }

    public static ChatterTopics parseChatterTopics(String json) {
        return (ChatterTopics) System.JSON.deserialize(json, ChatterTopics.class);
    }
    
    //object that represents a topic in the word cloud with weighting / description / link
    public class WordCloudTopic {
        public String text;
        public Integer weight;
        public String link;
        public HtmlAttribute html;
        
        public WordCloudTopic(ChatterTopic chatterTopic) {
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
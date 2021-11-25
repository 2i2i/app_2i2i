import 'package:app_2i2i/pages/cv/success.dart';
import 'package:flutter/material.dart';

enum CVPerson { imi, solli }

class CVPage extends StatelessWidget {
  CVPage({Key? key, required this.person}) : super(key: key);

  final CVPerson person;

  static const List<SuccessData> imiSuccesses = [
    const SuccessData(
        title: 'Reached the Encode Algorand Hackathon top 10 finale',
        timestamp: 1633500600,
        description: '''
Encode is an organisation that helps with the adoption of blockchains by running courses and hackathons.
It felt like the ideal framework to try to implement a project that I wanted to pursue: 2i2i, the mind market.
After intense weeks of hard work, we delivered the project very last minute and succeeded in making it into the finale.
'''),
    const SuccessData(title: '2i2i.app', timestamp: 1632614400, description: '''
The mind market.
A blockchain (Algorand) based exchange between energy and information.
Energy in the form of coins and information in the form of live video calls.

The idea is to provide a market for people's time. Everyone has some valuable information to offer.
This market allows for anyone to talk with anyone else at the fair market rate.

Includes:
• A credit-risk-free blockchain-based coin transaction system.
The users coins are locked in a Smart Contract during the live video call and released at the end.
Users can opt-in the system into any Algorand coin, without incurring losses to the system.
• A WebRTC based end-to-end encrypted and peer-to-peer live video calling system. Fully private and scalable.
• A Google Cloud based backend. Serverless, highly scalable, secure.
• A flutter based frontend, available as a WebApp, Android, iOS and DesktopApp.
'''),
    SuccessData(
        title:
            'Machine Learning based system to calculate microfinancing credit risk',
        timestamp: 1575158400,
        description: '''
Implemented a Machine Learning system written in julia to evaluate individual (retail) credit risk given for micro financing.
The system combined all available data, including:
• Financial history taken from the users bank account (given user consent).
• Behavioral data from the web app
• Other credit risk models

The in-sample and out-sample (live data) result were quite precise.
Evaluating statistics after changing parameters of the model showed results strongly inline with predicted results.
Even though each individual is unique, the portfolio credit risk can be modeled powerfully using Machine Learning.
'''),
    SuccessData(
        title: 'Automated online lending system',
        timestamp: 1569888000,
        description: '''
Implemented a high performance GCP based infrastructure to run a fully automated micro financing system.
• Serverless backend, highly scalable and secure.
• IT infrastructure based on GCP.
• Connected to a machine learning based credit risk model.
• Frontend written in vue: I wrote the first version, which was improved by frontend pros.

The system itself was shutdown due to lack of funding even though the tech worked well.
'''),
    SuccessData(
        title: 'Quasi Monte Carlo with PCA implementation',
        timestamp: 1433116800,
        description: '''
Implemented a highly performant quasi monte carlo algorithm with PCA.
• Written in julia
• Payout and diffusion equations were run time compiled from julia syntax allowing the user to evaluate any contract based.
• C level speed.
• In partnership with Axpo AG, Switzerland.
'''),
    SuccessData(
        title: 'Web app using .NET', timestamp: 1451606400, description: '''
Together with another software engineer, we implemented a front end client-facing web app for Axpo AG, Switzerland.
This was a replacement for an existing app, which Axpo had asked me to improve. The original version had cost hundreds of thousands of Swiss Franks and several years to create.
The original app was extremely buggy, e.g. it needed a daily server restart.
Instead of improving the existing app, I insisted and remade everything from scrath in 2 weeks. The new version was stable and much faster than the original.
We received bonus rewards from Axpo beyond the agreed renumeration for this extra ordinary effort.
'''),
    SuccessData(
        title: 'Prophet: A system to run server models in various languages',
        timestamp: 1420070400,
        description: '''
This framework allowed quants to write (financial) models in various languages.
No matter the language chosen, the users could run the models in the Excel frontend.
• Languages supported: C#, Python, julia, VBA.
• RabbitMQ for messaging.
• Google protobuf for encoding.
'''),
    SuccessData(
        title: 'Fully automated financial trades execution system',
        timestamp: 1420070400,
        description: '''
An API to execute trades with brokers. Highly performant due to the technologies chosen.
• Supported platforms: FIX, IB, WebOE.
• Written in julia and Java.
• Communication with ZeroMQ.
            '''),
// Each of which is based on economic and financial maths theory. All strategies are out-of-sample tested over decades of data.
    SuccessData(
        title: 'Fully automated trading system',
        timestamp: 1420070400,
        description: '''
A suite of systems that allocate funds towards to financial markets.
Includes:
• A system to combine a portfolio of strategies.
• A portfolio management system to 'optimally' allocate funds amongst and within the strategies.
• A trade execution ssytem to send trades to various brokers and book keep the positions.
• Automated data input, cleaning, transformation.
• A robust, N dimensional optimisation algorithm to find optimums in noisy data.
• A machine learning suite used in some of the strategies.

Result: The system has been running successfully since 2011. It has achieved good results for its clients and has won several awards.
It still runs fully automated, without intervention or change.
'''),
    SuccessData(
        title: 'Private video chat web app using WebSockets',
        timestamp: 1435708800,
        description: '''
• Implemented a simple web app right after discovering WebSockets.
• My opinion was that peer-to-peer web app data communications will revolutionise the world.

Result: It worked and was used by family members only. Never marketed.
'''),
    SuccessData(
        title: 'GPU computing implementations',
        timestamp: 1370044800,
        description: '''
• Implemented a few algorithms using CUDA.
• Formulation of existing models in linear algebraic terms.
• Achieved the expected, super fast speeds.
'''),
    SuccessData(
        title: 'Implementation of a quantitative trading system',
        timestamp: 1333238400,
        description: '''
• Implemenation of several trading models in Matlab.
• A portfolio and trades management system in Matlab.
            '''),
    SuccessData(
        title: 'Fully automated financial trades execution system',
        timestamp: 1330560000,
        description: '''
• Implemenation of a trades execution system in C#.
• A C# GUI to admin the system.
• Connected to CQG and IB.
            '''),
    SuccessData(
        title:
            'Novel model for portfolio optimization with significant performance improvement',
        timestamp: 1338508800,
        description: '''
First I implemented around 10 different models for portfolio optimisation found in white papers and compared their 'quality'.
The quality was based on backtested performance of a portfolio of alpha generating strategies.
I then formulated a novel model for portfolio optimisation. This model was simpler than any that I had found and the 'quality' was significantly higher as well.
This model has been the basis of multiple successful trading strategies since.
This model is not published, though I would like to publish it. Not sure about legality, as I formulated this whilst working for a Swiss hedge fund.
'''),
    SuccessData(
        title: 'Heston stochastic vol model implemetation',
        timestamp: 1293840000,
        description: '''
• Implementated and wrote a white paper on a Heston stochastic volatility model to evaluate complex financial products.
• Implementated in C++.
• Work done for UBS.
'''),
    SuccessData(
        title: 'Centralised Smart contracts',
        timestamp: 1275350400,
        description: '''
Having the ability to evaluate arbitraty contracts, based on Monte Carlo simulations was considered a valuable goal at UBS.
My manager had estimated that this project would require 6 months. Since there were always more urgent projects at hand, this project was never green lighted.
Over a weekend, I realised that instead of creating our own smart contract language, we could simply use Lua.
The contract written in Lua could be runtime compiled into C and then embedded into our existing C++ Monte Carlo engine.
Insisting on my idea, I implemented this solution in less than 3 days.
For this valuable contribution, I received monetary renumeration. However, I actually rather wanted renumeration in time.
Since I had saved UBS 6 months, I wanted 1 month off to spend with my newborn kids. UBS' refusal led me to accerate my independence from employers.
'''),
    SuccessData(
        title: 'Flights meta search', timestamp: 1243836600, description: '''
• Implemented a flexible flights search.
• Users needed to choose 4 parameters: earliest departure, latest return, shortest and longest duration.
• Based on these parameters, the app made multiple searches on ebookers (which allowed +- 3 day searches).
• The result was a triangular matrix showing the best prices.
• I used this tool personally for years to find cheap flights for my family.
• The app was never commersialised based on a flawed understanding of e-business: I thought ebookers (or any other site), does not actually like my traffic and could ban me any second.
'''),
    SuccessData(
        title: 'System to beat a Casino',
        timestamp: 1159660800,
        description: '''
• Having found a brand new game in a casino, I realised a flaw in the game.
• The following work was based on the games' rules, as written in their brochure and as witnessed when the game was introduced.
• I formulated the theoretical model that should predict the outcome of the game to a significant degree.
• I implemented the model into a phone. This was pre smart phones and I think I had one of the first programmable phones (Nokia, C++).
• The phone would receive input about the game via button clicks and would vibrate to alert if a positive outcome was expected, in which case the player should bet.
• Since the game in question is a physical game (similar to roulette), the model had 2 free parameters that would be calibrated based on actual data (based on the physical properties, such as resistance).
• After implementation (and travelling; it took me 1 year to return), I arrived at the casino to test the system.
• The calibration and the predictions were very accurate and precise.
• Unfortunatle, the casino had realised their mistake during this year and amended a rule which rendered my system useless. The change was that betting was to be done before turning the wheels (no "rien ne va plus").
• All of this was legal, but obviously the casino would not like it.
'''),
    SuccessData(
        title: 'Achieved 1.0 in Math Vordiplom',
        timestamp: 1054425600,
        description: '''
• Achieved near perfect grade in Math Vordiplom (halfway degree), which is the result of 4(?) oral exams after the first two years of studies.
• At the Humboldt University of Berlin, in pure Math.
• I quit university for personal reasons after this.
            '''),
    SuccessData(
        title: 'Won a pattern recognition competition run by Prof. Ziegler',
        timestamp: 986083200,
        description: '''
• Entered a competition run by Prof. Ziegler at the Technical University of Berlin.
• The competition was to write a algorithm to predict binary human choices.
• Humans were asked to enter 1 xor 0 thousands of times, as randomly as possible.
• Prof. Ziegler explained that he himself competed amongst professors and researchers at a math conference with the exact same goal. And his algorithm was the winner.
• My algorithm ended up winning and beating Prof. Zieglers' algorithm. My result was ca. 82% accuracy.
• Received a signed book by Prof. Ziegler which I soon lent to a friend --- friend, where are you nowadays? The book was a collection of the most beautiful Math proofs, written by Prof. Zieglier.
'''),
    SuccessData(
        title: 'Coded system to archive incoming fax as digital documents',
        timestamp: 988675200,
        description: '''
• On arriving fax, the system saved and archived the document digitally.
• Written for Carano Software, Berlin.
            '''),
    SuccessData(
        title:
            'Coded neural network for audio vowel classification incl. GUI for admin',
        timestamp: 993945600,
        description: '''
• Given audio recordings of each (German) vowel, the system should learn to categorise into vowels.
• MLP as neural architecture.
• FFT for audio signal transformation.
• Coded at the Technical University of Berlin.
• Machine Learning code in C++.
• GUI in tcl/tk.
• Result: I worked on this project alone, whereas others worked in teams. It was an intensive summer, of coding day and night, practically living at the university. At the end, after nearly losing my mind, the system worked! It was one of the most amazing things I had seen: A machine had learned to recognise human vowels from audio. That was the beginning of my love for Machine Learning.
'''),
    SuccessData(
        title: 'Attended and passed Analysis at uni during high school',
        timestamp: 904608000,
        description: '''
Started attending university Math lectures at the age of 16, two years before graduating high school. It was where I belonged, on the green campus of the Free University of Berln.
I did the homework, passed the courses and received the credit which I could have used later.
            '''),
    SuccessData(
        title: 'Ski teacher certification',
        timestamp: 838857600,
        description: '''
At the age of 14, I entered a ski teacher certification program (run by the Wiener Ski Verband, Austria), as a means to ski cheaply. Even though the minimum age was 15, I participated, worked hard and passed the exams (barely).
This made me a qualified ski teacher. Interestingly, I had just started skiing 2 years earlier. Everyone else attending the program had been skiing since their childhood. It would have even seemed that skiing was not 'for me', as I did not enjoy the cold, was scared of heights and fast speeds, was thin and weak and not well balanced.
Yet, I did enjoy it and skiied so much in the two years before these exams, that I made it. Barely, but I made it.
            '''),
    SuccessData(
        title: 'German U18 water polo champion',
        timestamp: 928195200,
        description: '''
• German Champion of U18 in 1998.
• 4 times German Vice Champion of U16 and U18.
• Selected for the German national team, but refused to join as I did not want to attend the military service, which was a connected necessity.
'''),
    SuccessData(
        title: 'Coded graphical labyrinth game',
        timestamp: 825638400,
        description: '''
Since ca. 8 years old, I had been coding a lot. Most of them I cannot remember.
The one game I do remember was a graphical labyrinth game which only showed the immediate surroundings of the user.
I even remember coding and formatting my computer without a screen, which my mother took away, thinking that was the computer. That is how intimate I was with my computer. I knew what it was doing based on my commands and the sounds it would make.
            '''),
    SuccessData(
        title: 'Jumped from German D4 to D1 within 2 years',
        timestamp: 841536000,
        description: '''
When I just arrived in Germany, I joined an international school that offered 4 levels of German: D4 (beginners), D3B, D3A, D2 (fluent) and D1 (native).
The normal progression from D4 was to advance a level per year, until either D3A or D2 in best cases. D2 was mostly inhabited by kids that grew up in Germany with foreign parents.
I went from D4 to D2 within one year. After that success, I made it my goal to make it to D1, which was considered absurd. Despite the discouragement, I managed to join D1 after another year, in grade 9.
Though I was very proud of the achievement, it turned to be a mistake. I did not enjoy the class and should have just chilled in D2. Eventually, I asked to be moved back to D2.
Nonetheless, I count it as a sucesss.
            '''),
    SuccessData(
        title: 'Self derived formula to calculate curve length',
        timestamp: 786240000,
        description: '''
At age 13, I became curious as to how my Math teacher could calculate angels of a triangle so precisely. He told me about trigonometry.
I spent months self studying trigonometry and then calculus from a book at the library. The most advanced calculations that I was able to do, were integrals by using infinite sums of infinitisimal rectangles under a curve.
I still remmeber lying to a teacher about the self study out of shame and instead saying that someone taught me.
Soon I asked another teacher what else one could calculate in Calculus. He mentioned that curve lengths are much more difficult than areas under a curve.
It took me weeks of thinking and finally I woke up one morning with the answer: Sum infinate infinitisimal triangle hypothenuses using pythagoras.
After deriving and applying the formula, I tested the result vs an applied maths app. The result matched and this achievement became my proudest.
            '''),
    SuccessData(
        title: 'Skipped grades 3 and 4', timestamp: 683683200, description: '''
Unfortunatle, due to personal reasons, I never enjoyed school. When changing to a 'better' school, my father suggested I take the exam for the next level up.
I did and passed, after which my father suggested that I should take another exam for another level higher. I did and passed again, resulting in me skipping grades 3 and 4.
I always count it as a success, just because I did not like school. Though now, I am not sure whether it was a good idea and am not sure whether to advise the same for others in a similar situation.
            '''),
    SuccessData(
        title: 'Won neighbourhood chess championship',
        timestamp: 688953600,
        description: '''
At a tender age and after having played chess just a few times, I managed to win 3 games at the neighbourhood chess championship (open to all ages), playing only against adults and defeating the reigning champion in the final.
I always considered this a reflection on the quality of the other chess players, since I was basically a beginner. After telling the story to my family last year, they urged my to rethink it as my own success. So I do now.
My chess 'career' consisted of playing slightly seriously as a tennager, achieving an ELO of ca. 1900 and stopping after realising the need to study openings.
I did earn pocket money over many years to come.
            '''),
    SuccessData(
        title: 'Raised 8MM CHF for ecamos',
        timestamp: 1370044800,
        description: '''
ecamos is a hedge fund in Switzerland. After joining them as a partner, my role was actually Head of Research, Trading and IT.
I did however end up giving most presentations and raised 8MM CHF, which was the highest ticket at that moment.
Since I geniunely dislike 'selling' anything, this was an achievement outside my comfort zone, begotten via a year long correspondence with the client.
            '''),
    SuccessData(
        title: 'Worked at UBS QRC', timestamp: 1249084800, description: '''
I had the amazing pleasure of working at the QRC Team at UBS, in Zurich, Switzerland.
The QRC (Quantitative Risk Control) team consisted of the most talented indivuals that I had ever seen.
Not only were the team members mostly PhDs in Math or Theoretical Physics, they were Olympiad Medalist winners or similar.
And then there was me.
Getting in was an extremely difficult experience. After being told 'no' by HR, I insisted and got an interview.
Conducting the first interviews on the phone, I had to solve Math problems in my head because I thought it would just be a friendly call. I was wrong.
Afterwards, I spent an entire day being asked though Math questions by around 10 people. At the end, HR again rejected me, but the team wanted me.
Against all odds, I got the job. I would go on to get a 'record time' promotion, aparently 'unheard of', after less than 6 months at UBS, during the height of the 2009 financial crisis.
            '''),
    SuccessData(
        title: 'EUREX Exchange Trader Examination',
        timestamp: 1267401600,
        description: '''
Passed the exam.
            '''),
    SuccessData(
        title: 'Financial Risk Management Certification (GARP)',
        timestamp: 1262649600,
        description: '''
To get a better standing in the financial community, I applied, studied for and passed the FRM exam at GARP.
            '''),
    SuccessData(
        title: 'Trading system awards', timestamp: 1585699200, description: '''
The trading system that I created has won several awards over the years, including:
• Barclay Managed Funds Report #6 Past Five Years category for 2020-Q4
• BarclayHedge #3 for Diversified Traders Managing More Than 10MM for 2020.
• BarclayHedge #1 for Diversified Traders Managing More Than 10MM for 2020-11.
• BarclayHedge #4 for Diversified Traders Managing More Than 10MM for 2020-01.
• BarclayHedge #8 for CTAs Managing More Than 10M for 2019-11.
• Barclay Managed Funds Report #16 Past Three Years category for 2019-Q2.
• BarclayHedge #7 for Systematic Traders for 2018-12.
• BarclayHedge #7 for CTAs Managing More Than 10MM for 2018-01.
• Barclay Managed Funds Report #10 Past Year category for 2017-Q4.
• Hedge Funds Review (Europe): Best Managed Futures CTA Emerging Manager 2017.
• CTA Intelligence: European Performance Awards 2017 Winner.
• HFM European Performance Awards 2017: Best Newcomer.
• Best CTA Multi Strategy Fund Manager - Europe - alternativeinvestmentawards
'''),
    SuccessData(
        title: 'Winner of Swiss ‘Quiz on Korea 2013’',
        timestamp: 1370044800,
        description: '''
I joined a competition called 'Quiz on Korea'. I managed to (barely) win the Swiss national competition.
This made me the Swiss representative at the international 'Quiz on Korea' world championships in Seoul. I did not do well at the finals, but still consider it a success to have made that far.
            '''),
    SuccessData(
        title: 'Intercontinental move to Canada',
        timestamp: 1627862400,
        description: '''
Moving to North America is always a challenge. For our kids education, we decided to take on this adventure.
We arrived in Canada on the same day that our Encode competition started. It was quite tough managing the competition whilst settling into a completely new place.
After getting the visa, arriving, getting a car, a house, I consider this a success.
            '''),
  ];

  static const List<SuccessData> solliSuccesses = [
    const SuccessData(
        title: 'Intercontinental move to Canada',
        timestamp: 1627862400,
        description: '''
Moving to North America is always a challenge. For our kids education, we decided to take on this adventure.
We arrived in Canada on the same day that our Encode competition started. It was quite tough managing the competition whilst settling into a completely new place.
After getting the visa, arriving, getting a car, a house, I consider this a success.
            '''),
    const SuccessData(
        title: 'Reached the Encode Algorand Hackathon top 10 finale',
        timestamp: 1633500600,
        description: '''
Encode is an organisation that helps with the adoption of blockchains by running courses and hackathons.
It felt like the ideal framework to try to implement a project that I wanted to pursue: 2i2i, the mind market.
After intense weeks of hard work, we delivered the project very last minute and succeeded in making it into the finale.
'''),
    const SuccessData(title: '2i2i.app', timestamp: 1632614400, description: '''
The mind market.
A blockchain (Algorand) based exchange between energy and information.
Energy in the form of coins and information in the form of live video calls.

The idea is to provide a market for people's time. Everyone has some valuable information to offer.
This market allows for anyone to talk with anyone else at the fair market rate.

Includes:
• A credit-risk-free blockchain-based coin transaction system.
The users coins are locked in a Smart Contract during the live video call and released at the end.
Users can opt-in the system into any Algorand coin, without incurring losses to the system.
• A WebRTC based end-to-end encrypted and peer-to-peer live video calling system. Fully private and scalable.
• A Google Cloud based backend. Serverless, highly scalable, secure.
• A flutter based frontend, available as a WebApp, Android, iOS and DesktopApp.

My contribution has been mainly towards design and operations of development.
'''),
    const SuccessData(
        title: 'Writing Awards',
        timestamp: 1070150400,
        description:
            '''Won numerous awards  in the Essay category, Fiction category, and Poetry category.'''),
    const SuccessData(
        title: 'Art Awards',
        timestamp: 1007078400,
        description:
            '''Won prizes in calligraphy categories , fine art and design in various competitions.'''),
    const SuccessData(
        title: 'Teaching',
        timestamp: 1196380800,
        description:
            '''With a sense of vocation and duty,  taught children from age 8—19that they can learn while having fun.
Jungchul Pro - 
Dasung - 
Zurich Korean School.'''),
    const SuccessData(
        title: 'Working for Trading company',
        timestamp: 1448841600,
        description:
            '''Identify the trends in the Swiss market, find the right products to import from Korea and the right importers, and update the accurate inventory system to generate revenue
Led the customs clearance without a hitch by translating the proper etiquette for the strict censorship of the Ministry of Food and Drug Safety.'''),
    const SuccessData(
        title: 'Exporting Products',
        timestamp: 1512000000,
        description:
            '''Supply European (Germany, Switzerland) manufactured products to Korean buyers
Contributes to the smooth supply of products by playing an efficient bridge role between manufacturers and forwarders buyers.'''),
  ];

  List<SuccessData> sortedSuccessList(List<SuccessData> successList) {
    List<SuccessData> sortedList = new List<SuccessData>.from(successList);
    sortedList.sort((s1, s2) => s1.timestamp < s2.timestamp ? 1 : -1);
    return sortedList;
  }

  List<Success> createSuccessWidgets(List<SuccessData> successDataList) {
    List<Success> successList = [];
    for (int i = 0; i < successDataList.length; i++) {
      Color backgroundColor = i % 2 == 0
          ? Color.fromRGBO(223, 239, 223, 1)
          : Color.fromRGBO(197, 234, 197, 1);
      Success success =
          Success(data: successDataList[i], backgroundColor: backgroundColor);
      successList.add(success);
    }
    return successList;
  }

  Widget disclaimer() {
    return ListTile(
      title: Text(
          'All times above are (very) approximate. The facts above are the persons successes, without humility :). Weaknesses/"failures" are not mentioned.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person.toString()),
      ),
      body: ListView(
        children: [
          ...createSuccessWidgets(sortedSuccessList(
              person == CVPerson.solli ? solliSuccesses : imiSuccesses)),
          disclaimer()
        ],
      ),
    );
  }
}

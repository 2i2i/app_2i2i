import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/faq_cv_provider/cv_provider.dart';
import '../../../infrastructure/providers/faq_cv_provider/faq_provider.dart';

class CvKeywordsList extends ConsumerWidget {
  const CvKeywordsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cvProviderModel = ref.watch(cvProvider);
    return Card(
      color: cvProviderModel.isOpenSuggestionView?Theme.of(context).cardColor:Theme.of(context).scaffoldBackgroundColor,
      elevation: cvProviderModel.isOpenSuggestionView?1.0:0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cvProviderModel.keywordList.isNotEmpty) Divider(color: Colors.transparent,height: 4),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                cvProviderModel.keywordList.length,
                (index) => InkResponse(
                  onTap: () => cvProviderModel.removeInKeywordList(
                      cvProviderModel.keywordList[index]),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30)),
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          "${cvProviderModel.keywordList[index]}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              ?.copyWith(color: Theme.of(context).cardColor),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.close,
                          color: Theme.of(context).cardColor,
                          size: 14,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (cvProviderModel.keywordList.isNotEmpty) Divider(color: Colors.transparent,height: 4),
          SuggestionList(cvProviderModel,context),
        ],
      ),
    );
  }

  Widget SuggestionList(CVProviderModel cvProviderModel,BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: cvProviderModel.isOpenSuggestionView
          ? MediaQuery.of(context).size.width*0.45
          : 0,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(6),
          child: Wrap(
            children: List.generate(
              cvProviderModel.keywords.length,
                  (index) => InkResponse(
                onTap: () => cvProviderModel
                    .addInKeywordList(cvProviderModel.keywords[index]),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30)),
                  margin: EdgeInsets.all(4),
                  padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    "${cvProviderModel.keywords[index]}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_expense/entity/tbl_template.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/alert_service.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  ScrollController scrollController = ScrollController();
  List<TblTemplate> templates = [];
  bool isFabVisible = true;

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // scrolling down
        if (isFabVisible) {
          setState(() => isFabVisible = false);
        }
      } else if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward ||
          scrollController.position.atEdge && scrollController.offset == 0) {
        // scrolling up or at the top
        if (!isFabVisible) {
          setState(() => isFabVisible = true);
        }
      }
    });
    super.initState();
    init();
  }

  void init() async {
    Response templateResponse = await templateService.getAllTemplates();
    if (templateResponse.isException) return;
    setState(() {
      templates = templateResponse.responseBody;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SMS Templates",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: Duration(milliseconds: 200),
        offset: isFabVisible ? Offset(0, -0.2) : Offset(0, 2),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            heroTag: "SMS FAB",
            onPressed: () async {
              log("clicked fab");
              var result = await Navigator.pushNamed(
                context,
                "/addTemplate",
                arguments: TblTemplate.empty(),
              );
              if (null != result && result is List<TblTemplate>) {
                setState(() {
                  templates.addAll(result);
                });
              }
            },
            tooltip: "Add Template",
            icon: Icon(Icons.add),
            label: Text("Add Template"),
          ),
        ),
      ),
      body: templates.isEmpty
          ? Center(
              child: Text(
                "No templates to be listed",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: Transform.rotate(
                    angle:
                        (45 + (templates[index].isCredit == 1 ? 180 : 0)) *
                        math.pi /
                        180,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: templates[index].isCredit == 1
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  title: Text(templates[index].patternName),
                  subtitle: Text(templates[index].txnType),
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            templates[index].pattern.pattern,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              label: Text("Edit"),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  "/addTemplate",
                                  arguments: templates[index],
                                );
                                if (result != null && result is TblTemplate) {
                                  setState(() {
                                    templates[index] = result;
                                  });
                                }
                              },
                              icon: Icon(Icons.edit),
                            ),
                            TextButton.icon(
                              label: Text("Delete"),
                              onPressed: () {
                                AlertService.twoButtonAlertDialog(
                                  "Are you sure you want to delete the template",
                                  true,
                                  context,
                                  "OK",
                                  () async {
                                    Navigator.pop(context);
                                    AlertService.showLoading(context);
                                    if (await templateService.deleteTemplate(
                                      templates[index].id ?? 0,
                                    )) {
                                      Navigator.pop(context);
                                      setState(() {
                                        templates.removeAt(index);
                                      });
                                    } else {
                                      Navigator.pop(context);
                                      AlertService.singleButtonAlertDialog(
                                        "Error while deleting the template",
                                        true,
                                        context,
                                        () => Navigator.pop(context),
                                      );
                                    }
                                  },
                                  "Cancel",
                                  () => Navigator.pop(context),
                                );
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_expense/entity/tbl_template.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/services/alert_service.dart';

class AddTemplatePage extends StatefulWidget {
  final TblTemplate template;
  const AddTemplatePage({super.key, required this.template});

  @override
  State<AddTemplatePage> createState() => _AddTemplatePageState();
}

class _AddTemplatePageState extends State<AddTemplatePage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController patternName;
  late TextEditingController pattern;
  late TextEditingController amountGroup;
  late TextEditingController dateGroup;
  late TextEditingController uniqueIdGroup;
  late TextEditingController merchantGroup;
  late TextEditingController txnType;
  late TextEditingController dateFormat;
  late int isCredit = 0;
  bool isUpdate = false;
  List<TblTemplate> templateList = [];

  @override
  void initState() {
    initEditControllers();
    super.initState();
  }

  void initEditControllers() {
    isUpdate = widget.template.patternName.isNotEmpty;
    patternName = TextEditingController(
      text: widget.template.patternName.isEmpty
          ? ""
          : widget.template.patternName,
    );
    pattern = TextEditingController(
      text: widget.template.pattern.pattern.isEmpty
          ? ""
          : widget.template.pattern.pattern,
    );
    amountGroup = TextEditingController(
      text: widget.template.amountGroup == 0
          ? ""
          : widget.template.amountGroup.toString(),
    );
    dateGroup = TextEditingController(
      text: widget.template.dateGroup == 0
          ? ""
          : widget.template.dateGroup.toString(),
    );
    uniqueIdGroup = TextEditingController(
      text: widget.template.uniqueIdGroup == 0
          ? ""
          : widget.template.uniqueIdGroup.toString(),
    );
    merchantGroup = TextEditingController(
      text: widget.template.merchantGroup == 0
          ? ""
          : widget.template.merchantGroup.toString(),
    );
    txnType = TextEditingController(
      text: widget.template.txnType.isEmpty ? "" : widget.template.txnType,
    );
    dateFormat = TextEditingController(
      text: widget.template.dateFormat.isEmpty
          ? "yyyy-mm-dd"
          : widget.template.dateFormat,
    );
  }

  Container getFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType textInputType = TextInputType.text,
    int? maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15, top: 10),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: themeController.value == ThemeMode.dark
            ? Colors.grey[800]
            : Colors.grey[200],
      ),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: textInputType,
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pop(context, templateList);
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          children: [
            Text(
              "${widget.template.patternName.isEmpty ? "Add" : "Edit"} Template",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Template Name"),
                  getFormField(
                    controller: patternName,
                    hintText: "Enter Template Name",
                  ),
                  Text("Pattern"),
                  getFormField(
                    controller: pattern,
                    hintText: "Enter Pattern",
                    maxLines: null,
                  ),
                  Text("Amount Group"),
                  getFormField(
                    controller: amountGroup,
                    hintText: "Enter Amount Group",
                    textInputType: TextInputType.number,
                  ),
                  Text("Date Group"),
                  getFormField(
                    controller: dateGroup,
                    hintText: "Enter Date Group",
                    textInputType: TextInputType.number,
                  ),
                  Text("Merchant Group"),
                  getFormField(
                    controller: merchantGroup,
                    hintText: "Enter Merchant Group",
                    textInputType: TextInputType.number,
                  ),
                  Text("UniqueId Group"),
                  getFormField(
                    controller: uniqueIdGroup,
                    hintText: "Enter UniqueId Group",
                    textInputType: TextInputType.number,
                  ),
                  Text("Transaction Type"),
                  getFormField(
                    controller: txnType,
                    hintText: "Enter Transaction Type",
                  ),
                  Text("Date Format"),
                  getFormField(
                    controller: dateFormat,
                    hintText: "Enter Date Format",
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        if (patternName.text.isEmpty ||
                            pattern.text.isEmpty ||
                            amountGroup.text.isEmpty ||
                            dateGroup.text.isEmpty ||
                            merchantGroup.text.isEmpty ||
                            uniqueIdGroup.text.isEmpty ||
                            txnType.text.isEmpty ||
                            dateFormat.text.isEmpty) {
                          AlertService.singleButtonAlertDialog(
                            "Please complete the form!!",
                            true,
                            context,
                            () => Navigator.pop(context),
                          );
                        } else {
                          AlertService.showLoading(context);
                          widget.template.amountGroup = int.parse(
                            amountGroup.text,
                          );
                          widget.template.dateGroup = int.parse(dateGroup.text);
                          widget.template.isCredit = isCredit;
                          widget.template.merchantGroup = int.parse(
                            merchantGroup.text,
                          );
                          widget.template.pattern = RegExp(pattern.text);
                          widget.template.patternName = patternName.text;
                          widget.template.txnType = txnType.text;
                          widget.template.uniqueIdGroup = int.parse(
                            uniqueIdGroup.text,
                          );
                          widget.template.dateFormat = dateFormat.text;
                          bool insertStatus = await templateService.addTemplate(
                            widget.template,
                          );
                          Navigator.pop(context);
                          if (insertStatus) {
                            AlertService.singleButtonAlertDialog(
                              "Successfully saved the template details.",
                              true,
                              context,
                              () {
                                if (isUpdate) {
                                  Navigator.pop(context);
                                  Navigator.pop(context, widget.template);
                                } else {
                                  templateList.add(
                                    TblTemplate.clone(widget.template),
                                  );
                                  formKey.currentState?.reset();
                                  patternName.clear();
                                  pattern.clear();
                                  amountGroup.clear();
                                  dateGroup.clear();
                                  merchantGroup.clear();
                                  uniqueIdGroup.clear();
                                  txnType.clear();
                                  Navigator.pop(context);
                                }
                              },
                            );
                          } else {
                            AlertService.singleButtonAlertDialog(
                              "Error while saving template",
                              true,
                              context,
                              () => Navigator.pop(context),
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        widget.template.patternName.isEmpty ? "ADD" : "UPDATE",
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

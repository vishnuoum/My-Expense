import 'package:my_expense/entity/tbl_template.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/db_service.dart';

class TemplateService {
  DBService dbService;

  TemplateService({required this.dbService});

  Future<bool> addTemplate(TblTemplate template) async {
    return await dbService.addTemplate(template);
  }

  Future<bool> deleteTemplate(int id) async {
    return await dbService.deleteTemplate(id);
  }

  Future<Response> getAllTemplates() async {
    return await dbService.getAllTemplates();
  }
}

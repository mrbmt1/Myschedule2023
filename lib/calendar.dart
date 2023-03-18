import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TextEditingController _subjectController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.now();
    _endTime = _startTime.replacing(hour: _startTime.hour + 1);
    _subjectController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour &&
                _endTime.minute <= _startTime.minute)) {
          _endTime = _startTime.replacing(hour: _startTime.hour + 1);
        }
      });
    }
  }

  void _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _saveSchedule() {
    // TODO: Save schedule to database or API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveSchedule(),
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

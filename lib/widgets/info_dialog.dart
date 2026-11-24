import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class InfoDialog extends StatefulWidget
{
  final String? title, description;
  final String? imageAssetPath;

  const InfoDialog({super.key, this.title, this.description, this.imageAssetPath,});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog>
{
  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      backgroundColor: Colors.grey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 12,),

                Text(
                  widget.title.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 27,),

                Text(
                  widget.description.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),

                if (widget.imageAssetPath != null &&
                    widget.imageAssetPath!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        widget.imageAssetPath!.trim(),
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          color: Colors.white10,
                          child: const Text(
                            "لم يتم العثور على صورة التواصل.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32,),

                SizedBox(
                  width: 202,
                  child: ElevatedButton(
                    onPressed: ()
                    {
                      Navigator.pop(context);

                      Restart.restartApp();
                    },
                    child: const Text(
                      "OK",
                    ),
                  ),
                ),

                const SizedBox(height: 12,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

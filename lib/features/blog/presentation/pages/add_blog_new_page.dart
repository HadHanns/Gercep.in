import 'dart:io';

import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/core/theme/app_pallete.dart';
import 'package:blog_app/core/utils/pick_image.dart';
import 'package:blog_app/core/utils/show_snackbar.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const AddNewBlogPage(),
      );
  const AddNewBlogPage({super.key});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
  File? fileOrImage;

  void selectImageOrFile() async {
    final pickedFileOrImage = await pickFileOrImage();
    if (pickedFileOrImage != null) {
      setState(() {
        fileOrImage = pickedFileOrImage;
      });
    }
  }

  Widget displayFileOrImage(File file) {
    // Cek apakah file adalah gambar berdasarkan ekstensi
    final fileName = file.path.split('/').last.toLowerCase();

    if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.zip') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.gif')) {
      // Jika file adalah gambar, tampilkan menggunakan Image.file
      return ClipRRect(
        borderRadius: BorderRadius.circular(12), // Menambahkan border radius
        child: Image.file(
          file,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text('Error displaying image.',
                style: TextStyle(color: Colors.red)),
          ),
        ),
      );
    } else {
      // Jika file bukan gambar, tampilkan fallback (contoh: nama file atau ikon)
      return ClipRRect(
        borderRadius: BorderRadius.circular(12), // Menambahkan border radius
        child: Container(
          color: Colors.transparent, // Background warna lebih terang
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.insert_drive_file,
                  size: 100,
                  color: Colors.blueGrey), // Ikon file dengan warna berbeda
              const SizedBox(height: 10),
              Text(
                'Selected file: $fileName',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500), // Menambahkan fontWeight
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  void uploadBlog() {
    if (formKey.currentState!.validate() &&
        selectedTopics.isNotEmpty &&
        fileOrImage != null) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      context.read<BlogBloc>().add(
            BlogUpload(
              posterId: posterId,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              fileimage: fileOrImage!,
              topics: selectedTopics,
            ),
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              uploadBlog();
            },
            icon: Icon(Icons.done_rounded),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogSucccess) {
            Navigator.pushAndRemoveUntil(
              context,
              BlogPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if(state is BlogLoading) {
            return const Loader();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    fileOrImage != null
                        ? GestureDetector(
                            onTap: selectImageOrFile,
                            child: SizedBox(
                                child: displayFileOrImage(
                              fileOrImage!,
                            )),
                          )
                        : GestureDetector(
                            onTap: () {
                              selectImageOrFile();
                            },
                            child: DottedBorder(
                              color: AppPallete.borderColor,
                              dashPattern: const [10, 4],
                              radius: Radius.circular(12),
                              borderType: BorderType.RRect,
                              strokeCap: StrokeCap.round,
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_open, size: 32),
                                    SizedBox(height: 15),
                                    Text(
                                      'Select your File or Image',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 12,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Liburan',
                          'Tugas',
                          'Jadwal',
                          'Materi Dosen',
                          'Info Kampus',
                        ]
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedTopics.contains(e)) {
                                      selectedTopics.remove(e);
                                    } else {
                                      selectedTopics.add(e);
                                    }
                                    setState(() {});
                                  },
                                  child: Chip(
                                    label: Text(
                                      e,
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Ubah warna teks menjadi putih
                                      ),
                                    ),
                                    color: MaterialStateProperty.all(
                                      selectedTopics.contains(e)
                                          ? const Color.fromARGB(
                                              255, 85, 197, 89)
                                          : null, // Default color jika tidak terpilih
                                    ),
                                    side: selectedTopics.contains(e)
                                        ? null
                                        : const BorderSide(
                                            color: AppPallete.borderColor,
                                          ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    BlogEditor(
                      controller: titleController,
                      hintText: 'Blog Title',
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    BlogEditor(
                      controller: contentController,
                      hintText: 'Blog Content',
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

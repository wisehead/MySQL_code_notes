#1.test_close_reader.cpp

```
main
--std::unique_ptr<afs2::AfsFileSystem> filesystem
--filesystem->start(true);
--
--//create file
--afs2::CreateOptions create_options;
--std::string file_name = file_name_perfix + std::to_string(random_num);
--filesystem->create(file_name.c_str(), create_options);
--
--//wirte file
--afs2::WriterOptions write_options;
--filesystem->open_writer(file_name.c_str(), write_options, &writer);
--CallbackChecker callback_checker1;
--afs2::SynchronizedClosure sync_done1;
--callback_checker1.sync_ptr = &sync_done1;
--writer->pwrite(0, data_to_write.c_str(), (2 * 1024 * 1024) , write_callback, &callback_checker1);
--sync_done1.wait();
--
--//read file
--filesystem->open_reader(file_name.c_str(), read_options, &reader);
--memset(user_buf, '\0', (2 * 1024 * 1024) + 1);
--CallbackChecker callback_checker2;
--afs2::SynchronizedClosure sync_done2;
--callback_checker2.sync_ptr = &sync_done2;
--reader->pread(0, user_buf, (2 * 1024 * 1024) , read_callback, &callback_checker2);
--sync_done2.wait();
--
--//close wirter
--sync_done1.reset();
--filesystem->close_writer(writer, close_callback, &sync_done1);
--sync_done1.wait();
--
--//close reader
--filesystem->close_reader(reader);
```

#2.test_mkdir_readdir_unlink.cpp

```
main
--std::unique_ptr<afs2::AfsFileSystem> filesystem
--filesystem->start(true);
--//创建父目录
--filesystem->mkdir(pdir_name.c_str());
--//判断在不在
--filesystem->exist(pdir_name.c_str());
--//创建子目录
--dir_name = dir_name_perfix + std::to_string(random_num);
--filesystem->mkdir(dir_name.c_str());
--//读目录项
--filesystem->readdir(pdir_name.c_str(), &dentry_list);
--//删除目录
--filesystem->remove(pdir_name.c_str(), true, afs2::TrashStrategy::NO_TRASH);
--//判断存在
--filesystem->exist(pdir_name.c_str());
```
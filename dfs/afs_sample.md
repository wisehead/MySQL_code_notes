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

```cpp
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

#3.test_multiblock_async_write_flush_sync.cpp

```cpp
main
--std::unique_ptr<afs2::AfsFileSystem> filesystem
--filesystem->start(true);
--//create file
--afs2::CreateOptions create_options;
--filesystem->create(file_name.c_str(), create_options);
--afs2::WriterOptions write_options;
--filesystem->open_writer(file_name.c_str(), write_options, &writer);
--//1st wirte, 0 + 0.5MB
--data_to_write.resize((512 * 1024), 'a');
--CallbackChecker callback_checker1;
--callback_checker1.expected_length = (512 * 1024);
--callback_checker1.sync_ptr = nullptr;
--callback_checker1.serial_num = 1;
--writer->pwrite(0, data_to_write.c_str(), (512 * 1024) , write_callback, &callback_checker1);
--//2nd write，0.5MB + 1.5MB
--callback_checker2.serial_num = 2;
--writer->pwrite(512 * 1024, data_to_write.c_str(), ((512 + 1024) * 1024) , write_callback, &callback_checker2);
--//3rd write, 2MB + 0.5MB
--callback_checker3.serial_num = 3;
--writer->pwrite(2 * 1024 * 1024, data_to_write.c_str(), (512 * 1024) , write_callback, &callback_checker3);
--//4th write, 2.5MB + 1.5MB
--callback_checker4.serial_num = 4;
--writer->pwrite((2 * 1024 * 1024) + (512 * 1024), data_to_write.c_str(), ((512 + 1024) * 1024) , write_callback, &callback_checker4);
--//flush 4MB
--callback_checker5.serial_num = 5;
--writer->flush(flush_callback, &callback_checker5);
--//sync
--callback_checker6.serial_num = 6;
--writer->sync(sync_callback, &callback_checker6);
--//close wirter
--filesystem->close_writer(writer, close_callback, &sync_done1);
--//open reader
--filesystem->open_reader(file_name.c_str(), read_options, &reader);
--//0 --> 0.5MB
--reader->pread(0, user_buf, (512 * 1024) , read_callback, &callback_checker2);
--//0.5MB --> 1MB
--reader->pread((512 * 1024), user_buf, (1024 * 1024) , read_callback, &callback_checker3);
```

#4:test_multiblock_async_writehole.cpp

```cpp
main
--filesystem->start(true);
--filesystem->create(file_name.c_str(), create_options);
--filesystem->open_writer(file_name.c_str(), write_options, &writer);
--//0 , 0.5MB
--writer->pwrite(0, data_to_write.c_str(), (512 * 1024) , write_callback, &callback_checker1);
--//0.5MB , 1.5MB
--writer->pwrite(512 * 1024, data_to_write.c_str(), ((512 + 1024) * 1024) , write_callback, &callback_checker2);
--//2MB, 0.5MB
--writer->pwrite(2 * 1024 * 1024, data_to_write.c_str(), (512 * 1024) , write_callback, &callback_checker3);
--//2.5MB, 1.5MB
--writer->pwrite((2 * 1024 * 1024) + (512 * 1024), data_to_write.c_str(), ((512 + 1024) * 1024) , write_callback, &callback_checker4);
--//close writer
--filesystem->close_writer(writer, close_callback, &sync_done1);
--filesystem->open_reader(file_name.c_str(), read_options, &reader);
--//read 0, 0.5MB
--reader->pread(0, user_buf, (512 * 1024) , read_callback, &callback_checker2);
--//read 0.5MB, 1MB
--reader->pread((512 * 1024), user_buf, (1024 * 1024) , read_callback, &callback_checker3);
--//random read
--offset = base::fast_rand_less_than(1024 * 1024 - 1);
--reader->pread(offset , user_buf, (1024 * 1024) - offset , read_callback, &callback_checker3);
```

















_checkDATADir()
{
  if [ ! -d $PGDATA ] ; then
    echo ERROR: [$PGDATA], no such directory 
    return 1;
  fi;

  return 0;
}

